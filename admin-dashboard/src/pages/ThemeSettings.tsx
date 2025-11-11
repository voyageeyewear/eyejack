import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { themeAPI } from '../lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Label } from '../components/ui/Label';
import { Save, Palette } from 'lucide-react';
import { useState } from 'react';

export function ThemeSettings() {
  const queryClient = useQueryClient();
  const [editedSettings, setEditedSettings] = useState<any>({});

  const { data: themeSettings, isLoading } = useQuery({
    queryKey: ['theme-settings'],
    queryFn: () => themeAPI.getAll(),
  });

  const updateMutation = useMutation({
    mutationFn: ({ key, data }: { key: string; data: any }) =>
      themeAPI.update(key, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['theme-settings'] });
      setEditedSettings({});
    },
  });

  const handleSave = (setting: any) => {
    const editedValue = editedSettings[setting.theme_key];
    if (editedValue !== undefined) {
      updateMutation.mutate({
        key: setting.theme_key,
        data: {
          ...setting,
          theme_value: editedValue,
        },
      });
    }
  };

  const handleInputChange = (key: string, value: any) => {
    setEditedSettings({
      ...editedSettings,
      [key]: value,
    });
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  const settings = themeSettings?.data?.data || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Palette className="h-8 w-8 text-primary" />
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Theme Settings</h1>
          <p className="text-gray-600 mt-2">
            Customize your app's colors, styles, and global settings
          </p>
        </div>
      </div>

      <div className="grid gap-6">
        {settings.map((setting: any) => {
          const currentValue =
            editedSettings[setting.theme_key] !== undefined
              ? editedSettings[setting.theme_key]
              : setting.theme_value;
          const hasChanges = editedSettings[setting.theme_key] !== undefined;

          return (
            <Card key={setting.id}>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-lg">
                      {setting.theme_key
                        .split('_')
                        .map((word: string) => word.charAt(0).toUpperCase() + word.slice(1))
                        .join(' ')}
                    </CardTitle>
                    <CardDescription className="mt-1">
                      Type: {setting.theme_type}
                    </CardDescription>
                  </div>
                  {hasChanges && (
                    <Button onClick={() => handleSave(setting)} size="sm">
                      <Save className="mr-2 h-4 w-4" />
                      Save
                    </Button>
                  )}
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {setting.theme_type === 'color' ? (
                    <div className="flex gap-4 items-end">
                      <div className="flex-1">
                        <Label htmlFor={setting.theme_key}>Color Value</Label>
                        <Input
                          id={setting.theme_key}
                          type="text"
                          value={currentValue}
                          onChange={(e) =>
                            handleInputChange(setting.theme_key, e.target.value)
                          }
                          placeholder="#000000"
                        />
                      </div>
                      <div>
                        <Label htmlFor={`${setting.theme_key}-picker`}>
                          Preview
                        </Label>
                        <Input
                          id={`${setting.theme_key}-picker`}
                          type="color"
                          value={currentValue}
                          onChange={(e) =>
                            handleInputChange(setting.theme_key, e.target.value)
                          }
                          className="h-10 w-20"
                        />
                      </div>
                    </div>
                  ) : setting.theme_type === 'number' ? (
                    <div>
                      <Label htmlFor={setting.theme_key}>Value</Label>
                      <Input
                        id={setting.theme_key}
                        type="number"
                        value={currentValue}
                        onChange={(e) =>
                          handleInputChange(
                            setting.theme_key,
                            parseFloat(e.target.value)
                          )
                        }
                      />
                    </div>
                  ) : (
                    <div>
                      <Label htmlFor={setting.theme_key}>Value</Label>
                      <Input
                        id={setting.theme_key}
                        type="text"
                        value={currentValue}
                        onChange={(e) =>
                          handleInputChange(setting.theme_key, e.target.value)
                        }
                      />
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {settings.length === 0 && (
        <Card>
          <CardContent className="flex items-center justify-center py-12">
            <p className="text-gray-600">No theme settings found</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

