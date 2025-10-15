import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Users, Calendar, FileText, Package, LogOut, Building2 } from 'lucide-react';
import { signOut, supabase } from '@/lib/supabase';
import { toast } from 'sonner';

const Dashboard = () => {
  const { user, loading, userRole } = useAuth();
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    employees: 0,
    todayAttendance: 0,
    pendingLeaves: 0,
    assets: 0,
  });

  useEffect(() => {
    if (!loading && !user) {
      navigate('/auth');
    }
  }, [user, loading, navigate]);

  useEffect(() => {
    if (user) {
      fetchStats();
    }
  }, [user]);

  const fetchStats = async () => {
    try {
      // Fetch employees count
      const { count: empCount } = await supabase
        .from('employees')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'active');

      // Fetch today's attendance
      const today = new Date().toISOString().split('T')[0];
      const { count: attCount } = await supabase
        .from('attendance')
        .select('*', { count: 'exact', head: true })
        .eq('date', today);

      // Fetch pending leaves
      const { count: leaveCount } = await supabase
        .from('leaves')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'pending');

      // Fetch assets
      const { count: assetCount } = await supabase
        .from('assets')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'assigned');

      setStats({
        employees: empCount || 0,
        todayAttendance: attCount || 0,
        pendingLeaves: leaveCount || 0,
        assets: assetCount || 0,
      });
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  const handleSignOut = async () => {
    try {
      await signOut();
      toast.success('Signed out successfully');
      navigate('/auth');
    } catch (error) {
      toast.error('Error signing out');
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-pulse text-muted-foreground">Loading...</div>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Building2 className="h-8 w-8 text-primary" />
            <div>
              <h1 className="text-2xl font-bold">HR Management</h1>
              <p className="text-sm text-muted-foreground">Welcome back, {user.email}</p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            {userRole && (
              <span className="px-3 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary">
                {userRole.replace('_', ' ').toUpperCase()}
              </span>
            )}
            <Button variant="outline" onClick={handleSignOut}>
              <LogOut className="h-4 w-4 mr-2" />
              Sign Out
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4 mb-8">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Total Employees
              </CardTitle>
              <Users className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.employees}</div>
              <p className="text-xs text-muted-foreground mt-1">Active employees</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Today's Attendance
              </CardTitle>
              <Calendar className="h-4 w-4 text-success" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.todayAttendance}</div>
              <p className="text-xs text-muted-foreground mt-1">Checked in today</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Pending Leaves
              </CardTitle>
              <FileText className="h-4 w-4 text-warning" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.pendingLeaves}</div>
              <p className="text-xs text-muted-foreground mt-1">Awaiting approval</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Assets Assigned
              </CardTitle>
              <Package className="h-4 w-4 text-accent" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.assets}</div>
              <p className="text-xs text-muted-foreground mt-1">Currently in use</p>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>Common tasks and operations</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              <Button variant="outline" className="h-24 flex flex-col gap-2">
                <Users className="h-6 w-6" />
                <span>Manage Employees</span>
              </Button>
              <Button variant="outline" className="h-24 flex flex-col gap-2">
                <Calendar className="h-6 w-6" />
                <span>Mark Attendance</span>
              </Button>
              <Button variant="outline" className="h-24 flex flex-col gap-2">
                <FileText className="h-6 w-6" />
                <span>Leave Requests</span>
              </Button>
              <Button variant="outline" className="h-24 flex flex-col gap-2">
                <Package className="h-6 w-6" />
                <span>Manage Assets</span>
              </Button>
              <Button variant="outline" className="h-24 flex flex-col gap-2">
                <Building2 className="h-6 w-6" />
                <span>Company Settings</span>
              </Button>
              <Button variant="outline" className="h-24 flex flex-col gap-2">
                <FileText className="h-6 w-6" />
                <span>Generate Payslips</span>
              </Button>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
};

export default Dashboard;
