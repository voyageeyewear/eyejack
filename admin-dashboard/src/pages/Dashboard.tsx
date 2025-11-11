import { useQuery } from '@tanstack/react-query';
import { statsAPI } from '../lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/Card';
import { Layers, Palette, Activity, TrendingUp } from 'lucide-react';

export function Dashboard() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: () => statsAPI.getStats(),
  });

  const statsData = stats?.data;

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  const statCards = [
    {
      title: 'Total Sections',
      value: statsData?.totalSections || 0,
      description: `${statsData?.activeSections || 0} active`,
      icon: Layers,
      color: 'text-blue-500',
    },
    {
      title: 'Theme Settings',
      value: statsData?.totalThemeSettings || 0,
      description: 'Customization options',
      icon: Palette,
      color: 'text-purple-500',
    },
    {
      title: 'Active Sections',
      value: statsData?.activeSections || 0,
      description: 'Currently visible',
      icon: Activity,
      color: 'text-green-500',
    },
    {
      title: 'Section Types',
      value: statsData?.sectionTypes?.length || 0,
      description: 'Different layouts',
      icon: TrendingUp,
      color: 'text-orange-500',
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
        <p className="text-gray-600 mt-2">
          Welcome to Eyejack Admin Dashboard - Manage your app content in real-time
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat) => (
          <Card key={stat.title}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {stat.title}
              </CardTitle>
              <stat.icon className={`h-4 w-4 ${stat.color}`} />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stat.value}</div>
              <p className="text-xs text-gray-600">
                {stat.description}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Section Types Overview */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Section Types</CardTitle>
            <CardDescription>
              Available section layouts in your app
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {statsData?.sectionTypes?.map((type: string) => (
                <div
                  key={type}
                  className="flex items-center justify-between p-2 rounded-md bg-gray-100"
                >
                  <span className="text-sm font-medium">{type}</span>
                  <span className="text-xs text-gray-600">
                    {statsData.sectionsByType[type]} section(s)
                  </span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>
              Common tasks and operations
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <a
              href="/sections"
              className="flex items-center gap-2 p-3 rounded-md border border-gray-200 hover:bg-gray-50 transition-colors"
            >
              <Layers className="h-5 w-5 text-blue-600" />
              <div>
                <p className="text-sm font-medium">Manage Sections</p>
                <p className="text-xs text-gray-600">
                  Add, edit, or remove app sections
                </p>
              </div>
            </a>
            <a
              href="/theme"
              className="flex items-center gap-2 p-3 rounded-md border border-gray-200 hover:bg-gray-50 transition-colors"
            >
              <Palette className="h-5 w-5 text-blue-600" />
              <div>
                <p className="text-sm font-medium">Theme Settings</p>
                <p className="text-xs text-gray-600">
                  Customize colors and styles
                </p>
              </div>
            </a>
            <a
              href="/preview"
              className="flex items-center gap-2 p-3 rounded-md border border-gray-200 hover:bg-gray-50 transition-colors"
            >
              <Activity className="h-5 w-5 text-blue-600" />
              <div>
                <p className="text-sm font-medium">Preview Changes</p>
                <p className="text-xs text-gray-600">
                  See how your app looks
                </p>
              </div>
            </a>
          </CardContent>
        </Card>
      </div>

      {/* Info Card */}
      <Card className="border-blue-200 bg-blue-50">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <TrendingUp className="h-5 w-5 text-blue-600" />
            Real-Time Updates
          </CardTitle>
          <CardDescription>
            All changes are applied instantly to your app without requiring a rebuild!
          </CardDescription>
        </CardHeader>
        <CardContent className="text-sm text-gray-700">
          <p>
            This dashboard connects directly to your PostgreSQL database on Railway. 
            Any changes you make here will be reflected in the Flutter app immediately 
            when users refresh or reopen the app.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}

