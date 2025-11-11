import { useQuery } from '@tanstack/react-query';
import { previewAPI } from '../lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { RefreshCw, Eye, CheckCircle2, XCircle } from 'lucide-react';

export function Preview() {
  const { data: previewData, isLoading, refetch } = useQuery({
    queryKey: ['preview'],
    queryFn: () => previewAPI.getPreview(),
    refetchInterval: 5000, // Auto-refresh every 5 seconds
  });

  const sections = previewData?.data?.sections || [];
  const shopInfo = previewData?.data?.shopInfo;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Eye className="h-8 w-8 text-primary" />
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Live Preview</h1>
            <p className="text-gray-600 mt-2">
              See how your app looks with current settings
            </p>
          </div>
        </div>
        <Button onClick={() => refetch()} disabled={isLoading}>
          <RefreshCw className={`mr-2 h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {/* Shop Info */}
      {shopInfo && (
        <Card>
          <CardHeader>
            <CardTitle>Store Information</CardTitle>
            <CardDescription>Connected Shopify store details</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <p className="text-sm font-medium text-gray-600">Store Name</p>
                <p className="text-lg font-semibold">{shopInfo.name}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-600">Domain</p>
                <p className="text-lg font-semibold">{shopInfo.domain}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Sections Preview */}
      <div className="space-y-4">
        <h2 className="text-2xl font-bold">Active Sections ({sections.length})</h2>
        
        {sections.map((section: any, index: number) => (
          <Card key={section.id}>
            <CardHeader>
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="flex items-center justify-center w-6 h-6 rounded-full bg-primary text-primary-foreground text-xs font-bold">
                      {index + 1}
                    </span>
                    <CardTitle className="text-lg">{section.id}</CardTitle>
                  </div>
                  <CardDescription className="mt-2">
                    Type: {section.type}
                  </CardDescription>
                </div>
                <div className="flex items-center gap-2">
                  {section.settings ? (
                    <CheckCircle2 className="h-5 w-5 text-green-500" />
                  ) : (
                    <XCircle className="h-5 w-5 text-red-500" />
                  )}
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <details className="space-y-2">
                <summary className="cursor-pointer text-sm font-medium text-gray-600 hover:text-foreground">
                  View Configuration ({Object.keys(section.settings || {}).length} properties)
                </summary>
                <div className="mt-4">
                  <div className="p-4 bg-gray-100 rounded-md">
                    <pre className="text-xs overflow-auto max-h-96">
                      {JSON.stringify(section, null, 2)}
                    </pre>
                  </div>
                </div>
              </details>
            </CardContent>
          </Card>
        ))}
      </div>

      {sections.length === 0 && !isLoading && (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <XCircle className="h-12 w-12 text-gray-600 mb-4" />
            <p className="text-lg font-medium">No sections found</p>
            <p className="text-sm text-gray-600 mt-2">
              Add sections to see them appear here
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

