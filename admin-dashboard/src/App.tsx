import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { Sections } from './pages/Sections';
import { ThemeSettings } from './pages/ThemeSettings';
import { Preview } from './pages/Preview';
import Banners from './pages/Banners';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Dashboard />} />
            <Route path="sections" element={<Sections />} />
            <Route path="banners" element={<Banners />} />
            <Route path="theme" element={<ThemeSettings />} />
            <Route path="preview" element={<Preview />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;
