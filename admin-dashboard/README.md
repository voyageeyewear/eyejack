# Eyejack Admin Dashboard

A professional, elegant admin dashboard for managing the Eyejack Flutter app content in real-time.

## Features

- 📊 **Dashboard Overview**: View statistics and quick actions
- 🎨 **Sections Management**: Add, edit, delete, and reorder app sections
- 🎨 **Theme Settings**: Customize colors and global styles
- 👁️ **Live Preview**: See how your changes look in real-time
- ⚡ **Real-time Updates**: Changes are applied instantly without app rebuild
- 🌙 **Dark Mode Support**: Professional dark/light theme

## Tech Stack

- **React 18** with TypeScript
- **Vite** for fast development
- **Tailwind CSS** for styling
- **React Query** for data fetching
- **React Router** for navigation
- **Axios** for API calls
- **Lucide React** for icons

## Getting Started

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

The dashboard will be available at `http://localhost:5173`

### Build for Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Configuration

Create a `.env` file in the root directory:

```env
VITE_API_BASE_URL=https://motivated-intuition-production.up.railway.app
```

## Features Guide

### Dashboard
- View total sections, theme settings, and active sections
- Quick access to common actions
- Overview of section types

### Sections Management
- View all sections in order
- Toggle section visibility (active/inactive)
- Edit section settings with JSON editor
- Delete sections
- Drag to reorder (coming soon)

### Theme Settings
- Edit color values with color picker
- Modify text and number settings
- Changes apply instantly to the app

### Live Preview
- See current app configuration
- Auto-refreshes every 5 seconds
- View detailed section settings

## API Integration

The dashboard connects to your PostgreSQL backend via REST API:

- `GET /api/admin/sections` - Get all sections
- `POST /api/admin/sections` - Create new section
- `PUT /api/admin/sections/:id` - Update section
- `DELETE /api/admin/sections/:id` - Delete section
- `GET /api/admin/theme-settings` - Get theme settings
- `PUT /api/admin/theme-settings/:key` - Update theme setting
- `GET /api/admin/dashboard-stats` - Get dashboard statistics

## Deployment

### Railway (Recommended)

1. Create a new Railway project
2. Connect your GitHub repository
3. Add environment variable: `VITE_API_BASE_URL`
4. Deploy automatically on push

### Vercel

```bash
vercel --prod
```

### Netlify

```bash
netlify deploy --prod
```

## License

Proprietary - Eyejack Application
