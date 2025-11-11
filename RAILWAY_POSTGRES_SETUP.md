# 🚂 Railway PostgreSQL Setup Guide

## Step 1: Add PostgreSQL to Your Railway Project

### Via Railway Dashboard:

1. **Go to Railway Dashboard:**
   - Visit: https://railway.app
   - Login to your account

2. **Open Your Existing Project:**
   - Click on your project (where middleware is deployed)

3. **Add PostgreSQL Database:**
   ```
   - Click "+ New" button
   - Select "Database"
   - Choose "PostgreSQL"
   - Wait for provisioning (30-60 seconds)
   ```

4. **PostgreSQL Service Created!**
   - Railway automatically creates a new PostgreSQL service
   - Database is ready to use immediately

---

## Step 2: Get Database Connection URL

### Method 1: Via Dashboard (Easiest)

1. **Click on PostgreSQL service** in your project
2. **Go to "Variables" tab**
3. **Copy `DATABASE_URL`** value:
   ```
   postgresql://postgres:password@containers-us-west-xxx.railway.app:6379/railway
   ```

### Method 2: Via Connection String

Railway provides these variables automatically:
```
DATABASE_URL=postgresql://postgres:xxxxx@containers-us-west-xxx.railway.app:6379/railway
PGDATABASE=railway
PGHOST=containers-us-west-xxx.railway.app
PGPASSWORD=xxxxx
PGPORT=6379
PGUSER=postgres
```

---

## Step 3: Add DATABASE_URL to Middleware Service

### In Railway Dashboard:

1. **Go to your middleware service** (not PostgreSQL service)
2. **Click "Variables" tab**
3. **Add new variable:**
   ```
   Name: DATABASE_URL
   Value: ${{Postgres.DATABASE_URL}}
   ```
   *(Railway will auto-populate this from your PostgreSQL service)*

4. **Or manually add:**
   ```
   DATABASE_URL=postgresql://postgres:xxxxx@...
   ```

5. **Click "Add"**
6. **Service will automatically redeploy**

---

## Step 4: Run Seed Script

### Option A: Via Railway CLI (Recommended)

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Link to project
railway link

# Select your middleware service

# Run seed script
railway run node scripts/seedDatabase.js
```

### Option B: Via Local Development

1. **Create `.env` file** in `shopify-middleware/`:
   ```env
   DATABASE_URL=postgresql://postgres:xxxxx@containers-us-west-xxx.railway.app:6379/railway
   ```

2. **Run seed script:**
   ```bash
   cd shopify-middleware
   node scripts/seedDatabase.js
   ```

3. **Expected output:**
   ```
   🌱 Starting database seed...
   
   📊 Creating database tables...
   ✅ Tables created successfully
   
   📦 Seeding app sections...
   ✅ Created 9 sections
   
   🎨 Seeding theme settings...
   ✅ Created 3 theme settings
   
   📊 Database Status:
      - Sections: 9
      - Theme settings: 3
   
   ✅ Database seeded successfully!
   ```

---

## Step 5: Verify Database

### Via Railway Dashboard:

1. **Click on PostgreSQL service**
2. **Go to "Data" tab**
3. **Run query:**
   ```sql
   SELECT * FROM app_sections;
   ```
4. **Should see 9 rows** with all your sections!

### Via psql (if you have it installed):

```bash
# Connect to Railway PostgreSQL
psql "postgresql://postgres:xxxxx@containers-us-west-xxx.railway.app:6379/railway"

# List tables
\dt

# View sections
SELECT section_id, section_type, display_order FROM app_sections ORDER BY display_order;

# Exit
\q
```

---

## ⚠️ Important Notes

### 1. Database URL Format
```
postgresql://[user]:[password]@[host]:[port]/[database]
```

### 2. SSL Required
Railway PostgreSQL requires SSL connections. Our code handles this automatically:
```javascript
dialectOptions: {
    ssl: {
        require: true,
        rejectUnauthorized: false
    }
}
```

### 3. Connection Pooling
We limit connections to avoid exhausting Railway's free tier limits:
```javascript
pool: {
    max: 5,  // Maximum 5 connections
    min: 0,
    acquire: 30000,
    idle: 10000
}
```

---

## 🐛 Troubleshooting

### Error: "Connection refused"
**Solution:** Check that `DATABASE_URL` is correctly set in Railway variables

### Error: "SSL required"
**Solution:** Our config already handles this. Make sure you're using latest code.

### Error: "Too many connections"
**Solution:** Railway free tier limits connections. Increase `pool.max` to 3 instead of 5.

### Error: "Database does not exist"
**Solution:** Railway creates the database automatically. Use the exact `DATABASE_URL` provided.

---

## 📊 Railway Free Tier Limits

PostgreSQL on Railway free tier includes:
- ✅ 512 MB storage
- ✅ 5 GB outbound traffic/month
- ✅ Automatic backups
- ✅ SSL connections
- ✅ Public endpoint

**Our app usage:** ~10 MB (plenty of space!)

---

## 🎯 What's Next?

After database is seeded:
1. Update API endpoints to read from PostgreSQL
2. Create admin API endpoints
3. Build admin dashboard
4. Test everything

---

## ✅ Checklist

- [ ] Created PostgreSQL service on Railway
- [ ] Got `DATABASE_URL` from Railway
- [ ] Added `DATABASE_URL` to middleware service variables
- [ ] Ran seed script successfully
- [ ] Verified data in Railway dashboard
- [ ] Tested API connection

**Once complete, you're ready for the next phase!** 🚀

