import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Building2, Users, Calendar, FileText, Shield, Clock } from 'lucide-react';

const Index = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary/10 via-background to-accent/10">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Building2 className="h-10 w-10 text-primary" />
            <span className="text-2xl font-bold">HR Management</span>
          </div>
          <Button onClick={() => navigate('/auth')}>
            Get Started
          </Button>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-4 py-20 text-center">
        <h1 className="text-5xl font-bold mb-6 bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
          Modern HR Management System
        </h1>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          Streamline your workforce management with our comprehensive HR solution. 
          Built for Indian compliance with PAN, Aadhar, UAN, and ESIC support.
        </p>
        <div className="flex gap-4 justify-center">
          <Button size="lg" onClick={() => navigate('/auth')}>
            Start Free Trial
          </Button>
          <Button size="lg" variant="outline" onClick={() => navigate('/auth')}>
            Sign In
          </Button>
        </div>
      </section>

      {/* Features Grid */}
      <section className="container mx-auto px-4 py-20">
        <h2 className="text-3xl font-bold text-center mb-12">Everything You Need</h2>
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          <div className="p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
            <Users className="h-12 w-12 text-primary mb-4" />
            <h3 className="text-xl font-semibold mb-2">Employee Management</h3>
            <p className="text-muted-foreground">
              Comprehensive employee records with Indian compliance fields including PAN, Aadhar, UAN, ESIC
            </p>
          </div>

          <div className="p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
            <Clock className="h-12 w-12 text-success mb-4" />
            <h3 className="text-xl font-semibold mb-2">Attendance Tracking</h3>
            <p className="text-muted-foreground">
              Real-time attendance monitoring with sign-in/sign-out and automatic working hours calculation
            </p>
          </div>

          <div className="p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
            <Calendar className="h-12 w-12 text-warning mb-4" />
            <h3 className="text-xl font-semibold mb-2">Leave Management</h3>
            <p className="text-muted-foreground">
              Handle leave requests, approvals, and balance tracking with multiple leave types
            </p>
          </div>

          <div className="p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
            <FileText className="h-12 w-12 text-accent mb-4" />
            <h3 className="text-xl font-semibold mb-2">Payroll & Payslips</h3>
            <p className="text-muted-foreground">
              Automated payslip generation with PF, ESI, and tax deductions as per Indian regulations
            </p>
          </div>

          <div className="p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
            <Shield className="h-12 w-12 text-primary mb-4" />
            <h3 className="text-xl font-semibold mb-2">Asset Management</h3>
            <p className="text-muted-foreground">
              Track company assets with QR codes, assignments, and maintenance records
            </p>
          </div>

          <div className="p-6 rounded-lg border bg-card hover:shadow-lg transition-shadow">
            <Building2 className="h-12 w-12 text-success mb-4" />
            <h3 className="text-xl font-semibold mb-2">Multi-Branch Support</h3>
            <p className="text-muted-foreground">
              Manage multiple branches and locations from a single centralized platform
            </p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="container mx-auto px-4 py-20 text-center">
        <div className="max-w-3xl mx-auto p-12 rounded-2xl bg-gradient-to-r from-primary/10 to-accent/10 border">
          <h2 className="text-3xl font-bold mb-4">Ready to Get Started?</h2>
          <p className="text-lg text-muted-foreground mb-8">
            Join thousands of companies managing their workforce efficiently
          </p>
          <Button size="lg" onClick={() => navigate('/auth')}>
            Create Your Account
          </Button>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t py-8">
        <div className="container mx-auto px-4 text-center text-muted-foreground">
          <p>© 2024 HR Management System. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
};

export default Index;
