# Skill: Creating and Managing Prisma Migrations

## Description

This skill covers the complete workflow for creating, applying, troubleshooting, and managing database migrations with Prisma Migrate. It includes development workflows, production deployment, handling breaking changes safely, squashing migrations, and resolving common migration conflicts.

## Prerequisites

- Node.js (v18 or later)
- Prisma CLI installed (`npm install prisma --save-dev`)
- A configured `prisma/schema.prisma` with a valid `datasource` block
- `DATABASE_URL` set in `.env`
- A running database instance (PostgreSQL, MySQL, SQLite, SQL Server, or CockroachDB)

## Steps

### 1. Make Schema Changes

Edit `prisma/schema.prisma` to add, modify, or remove models and fields:

```prisma
// Adding a new model
model Category {
  id        String   @id @default(cuid())
  name      String   @unique
  slug      String   @unique
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([slug])
  @@map("categories")
}

// Adding a relation to an existing model
model Post {
  id         String    @id @default(cuid())
  title      String
  content    String?   @db.Text
  published  Boolean   @default(false)
  author     User      @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId   String
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: SetNull)
  categoryId String?
  createdAt  DateTime  @default(now())
  updatedAt  DateTime  @updatedAt

  @@index([authorId])
  @@index([categoryId])
  @@index([published, createdAt])
  @@map("posts")
}
```

### 2. Validate the Schema

Before creating a migration, ensure the schema is valid:

```bash
npx prisma validate
```

This catches syntax errors, invalid relations, and misconfigured fields before any SQL is generated.

### 3. Format the Schema

Keep the schema consistently formatted:

```bash
npx prisma format
```

### 4. Create a Development Migration

Generate and apply a migration to your development database:

```bash
npx prisma migrate dev --name add_categories
```

This command:
1. Generates a SQL migration file in `prisma/migrations/<timestamp>_add_categories/migration.sql`
2. Applies the migration to the development database
3. Regenerates the Prisma Client

**Review the generated SQL** before continuing:

```bash
cat prisma/migrations/*_add_categories/migration.sql
```

### 5. Preview Migration Without Applying

To see what SQL would be generated without applying:

```bash
npx prisma migrate diff \
  --from-schema-datamodel prisma/schema.prisma \
  --to-schema-datasource prisma/schema.prisma \
  --script
```

Or use the `--create-only` flag to generate the migration file without applying it:

```bash
npx prisma migrate dev --name add_categories --create-only
```

This lets you edit the SQL before applying with:

```bash
npx prisma migrate dev
```

### 6. Handle Breaking Changes Safely

For destructive changes (column renames, type changes, dropping columns), use a multi-step migration approach:

#### Renaming a Column

**Step 1** — Add the new column:
```bash
npx prisma migrate dev --name add_display_name --create-only
```

Edit the generated SQL:
```sql
-- Add the new column
ALTER TABLE "users" ADD COLUMN "display_name" TEXT;

-- Copy data from old column
UPDATE "users" SET "display_name" = "name";

-- Make the new column non-nullable
ALTER TABLE "users" ALTER COLUMN "display_name" SET NOT NULL;
```

Apply:
```bash
npx prisma migrate dev
```

**Step 2** — Update application code to use the new field name.

**Step 3** — Drop the old column in a subsequent migration:
```bash
npx prisma migrate dev --name drop_old_name_column
```

#### Changing a Column Type

```bash
npx prisma migrate dev --name change_price_type --create-only
```

Edit the generated SQL:
```sql
-- Add a new column with the target type
ALTER TABLE "products" ADD COLUMN "price_new" DECIMAL(10, 2);

-- Migrate data with type conversion
UPDATE "products" SET "price_new" = "price"::DECIMAL(10, 2);

-- Drop the old column
ALTER TABLE "products" DROP COLUMN "price";

-- Rename the new column
ALTER TABLE "products" RENAME COLUMN "price_new" TO "price";
```

### 7. Check Migration Status

View which migrations have been applied:

```bash
npx prisma migrate status
```

This shows:
- Applied migrations
- Pending migrations (not yet applied)
- Failed migrations (need resolution)

### 8. Deploy Migrations to Production

In production and CI/CD, use `migrate deploy` instead of `migrate dev`:

```bash
npx prisma migrate deploy
```

Key differences:
- **`migrate dev`** — interactive, creates migrations, resets on drift, runs seeds; for **development only**
- **`migrate deploy`** — non-interactive, applies pending migrations only; for **production/staging**

### 9. Reset the Database

To drop the database, re-create it, and apply all migrations:

```bash
# With confirmation prompt
npx prisma migrate reset

# Skip confirmation (for CI/CD)
npx prisma migrate reset --force
```

This also runs the seed script if configured.

### 10. Seed After Migration

Create or update `prisma/seed.ts`:

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Upsert to avoid duplicate key errors
  const adminUser = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      name: 'Admin',
      role: 'ADMIN',
    },
  });

  const categories = ['Technology', 'Science', 'Design'];
  for (const name of categories) {
    await prisma.category.upsert({
      where: { slug: name.toLowerCase() },
      update: {},
      create: {
        name,
        slug: name.toLowerCase(),
      },
    });
  }

  console.log('Seed complete:', { adminUser, categories });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

Configure in `package.json`:

```json
{
  "prisma": {
    "seed": "ts-node --compiler-options {\"module\":\"CommonJS\"} prisma/seed.ts"
  }
}
```

Run manually:

```bash
npx prisma db seed
```

### 11. Resolve Migration Conflicts

#### Drift Detected

When the database schema has drifted from migration history:

```bash
# Check for drift
npx prisma migrate diff \
  --from-migrations prisma/migrations \
  --to-schema-datasource prisma/schema.prisma

# Option A: Reset development database (loses data)
npx prisma migrate reset

# Option B: Baseline the database (for existing databases)
npx prisma migrate resolve --applied <migration_name>
```

#### Failed Migration

When a migration partially applies:

```bash
# Mark a failed migration as rolled back
npx prisma migrate resolve --rolled-back <migration_name>

# Fix the migration SQL and re-apply
npx prisma migrate dev
```

#### Team Conflicts

When multiple developers create concurrent migrations:

1. Pull the latest migrations from version control
2. Run `npx prisma migrate dev` to apply any new migrations
3. If conflicts exist, Prisma will prompt you to reset or resolve
4. Communicate with your team about overlapping schema changes

### 12. Squash Migrations

Over time, many small migrations accumulate. To clean up:

```bash
# 1. Back up your current migrations directory
cp -r prisma/migrations prisma/migrations.bak

# 2. Delete all migration folders
rm -rf prisma/migrations

# 3. Create a fresh baseline migration
npx prisma migrate dev --name baseline

# 4. In production, mark the baseline as applied
npx prisma migrate resolve --applied <baseline_migration_name>
```

**Warning**: Only squash when all environments are in sync. Never squash migrations that haven't been fully deployed.

## Verification

After creating and applying a migration:

```bash
# 1. Validate the schema
npx prisma validate

# 2. Check migration status — all should show as applied
npx prisma migrate status

# 3. Generate the client — types should reflect the new schema
npx prisma generate

# 4. Open Prisma Studio to inspect the database
npx prisma studio

# 5. Run your application's test suite
npm test
```

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Running `migrate dev` in production | Always use `migrate deploy` in production/staging |
| Editing already-applied migrations | Never edit applied migrations — create new ones |
| Forgetting to commit migration files | Always commit the `prisma/migrations/` directory |
| Data loss from `migrate reset` | Only use `reset` in development; back up data first |
| Drift after manual DB changes | Avoid manual schema changes; always use Prisma Migrate |
| Not reviewing generated SQL | Always review `migration.sql` before applying |
| Destructive changes in one step | Use multi-step migrations for renames, type changes, and drops |
| Ignoring `migrate status` in CI | Add `prisma migrate status` to CI checks to catch pending migrations |
