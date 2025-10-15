-- Create enum types
CREATE TYPE public.employment_status AS ENUM ('active', 'inactive', 'terminated');
CREATE TYPE public.leave_type AS ENUM ('casual', 'sick', 'earned', 'unpaid');
CREATE TYPE public.leave_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE public.asset_type AS ENUM ('laptop', 'desktop', 'mobile', 'tablet', 'other');
CREATE TYPE public.asset_status AS ENUM ('available', 'assigned', 'maintenance', 'retired');
CREATE TYPE public.gender_type AS ENUM ('male', 'female', 'other');
CREATE TYPE public.app_role AS ENUM ('super_admin', 'company_admin', 'hr_manager', 'employee');

-- Companies table
CREATE TABLE public.companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  location TEXT,
  email TEXT,
  phone TEXT,
  gst TEXT,
  pan TEXT,
  logo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Branches table
CREATE TABLE public.branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  location TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Profiles table (extends auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- User roles table (for role-based access control)
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role public.app_role NOT NULL,
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, role, company_id)
);

-- Employees table
CREATE TABLE public.employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE NOT NULL,
  branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
  employee_id TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  dob DATE,
  gender public.gender_type,
  address TEXT,
  designation TEXT,
  department TEXT,
  date_of_joining DATE,
  salary DECIMAL(10,2),
  pan TEXT,
  aadhar TEXT,
  bank_account TEXT,
  ifsc TEXT,
  uan TEXT,
  esic TEXT,
  status public.employment_status DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(company_id, employee_id)
);

-- Attendance table
CREATE TABLE public.attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES public.employees(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  sign_in TIME,
  sign_out TIME,
  working_hours DECIMAL(4,2),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(employee_id, date)
);

-- Leaves table
CREATE TABLE public.leaves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES public.employees(id) ON DELETE CASCADE NOT NULL,
  leave_type public.leave_type NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason TEXT,
  status public.leave_status DEFAULT 'pending',
  approved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Documents table
CREATE TABLE public.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES public.employees(id) ON DELETE CASCADE NOT NULL,
  document_type TEXT NOT NULL,
  document_name TEXT NOT NULL,
  document_url TEXT NOT NULL,
  uploaded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Payslips table
CREATE TABLE public.payslips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES public.employees(id) ON DELETE CASCADE NOT NULL,
  month INT NOT NULL,
  year INT NOT NULL,
  basic_salary DECIMAL(10,2) NOT NULL,
  hra DECIMAL(10,2),
  allowances DECIMAL(10,2),
  pf_deduction DECIMAL(10,2),
  esi_deduction DECIMAL(10,2),
  tax_deduction DECIMAL(10,2),
  other_deductions DECIMAL(10,2),
  net_salary DECIMAL(10,2) NOT NULL,
  generated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(employee_id, month, year)
);

-- Projects table
CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  start_date DATE,
  end_date DATE,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Project assignments table
CREATE TABLE public.project_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE NOT NULL,
  employee_id UUID REFERENCES public.employees(id) ON DELETE CASCADE NOT NULL,
  assigned_date DATE DEFAULT CURRENT_DATE,
  role TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(project_id, employee_id)
);

-- Assets table
CREATE TABLE public.assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  asset_type public.asset_type NOT NULL,
  serial_number TEXT,
  qr_code TEXT UNIQUE,
  status public.asset_status DEFAULT 'available',
  assigned_to UUID REFERENCES public.employees(id) ON DELETE SET NULL,
  assigned_date DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaves ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payslips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets ENABLE ROW LEVEL SECURITY;

-- Create function to check user role
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role public.app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- Create function to get user's company
CREATE OR REPLACE FUNCTION public.get_user_company(_user_id UUID)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id
  FROM public.user_roles
  WHERE user_id = _user_id
  LIMIT 1
$$;

-- RLS Policies for companies
CREATE POLICY "Users can view their own company"
ON public.companies FOR SELECT
USING (id = public.get_user_company(auth.uid()));

CREATE POLICY "Super admins can manage all companies"
ON public.companies FOR ALL
USING (public.has_role(auth.uid(), 'super_admin'));

-- RLS Policies for profiles
CREATE POLICY "Users can view their own profile"
ON public.profiles FOR SELECT
USING (id = auth.uid());

CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE
USING (id = auth.uid());

-- RLS Policies for user_roles
CREATE POLICY "Users can view their own roles"
ON public.user_roles FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Super admins can manage all roles"
ON public.user_roles FOR ALL
USING (public.has_role(auth.uid(), 'super_admin'));

CREATE POLICY "Company admins can manage company roles"
ON public.user_roles FOR ALL
USING (
  public.has_role(auth.uid(), 'company_admin') 
  AND company_id = public.get_user_company(auth.uid())
);

-- RLS Policies for employees
CREATE POLICY "Users can view employees in their company"
ON public.employees FOR SELECT
USING (company_id = public.get_user_company(auth.uid()));

CREATE POLICY "HR managers can manage employees"
ON public.employees FOR ALL
USING (
  public.has_role(auth.uid(), 'hr_manager') 
  OR public.has_role(auth.uid(), 'company_admin')
  OR public.has_role(auth.uid(), 'super_admin')
);

-- RLS Policies for attendance
CREATE POLICY "Employees can view their own attendance"
ON public.attendance FOR SELECT
USING (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
);

CREATE POLICY "HR can view all company attendance"
ON public.attendance FOR SELECT
USING (
  public.has_role(auth.uid(), 'hr_manager') 
  OR public.has_role(auth.uid(), 'company_admin')
);

CREATE POLICY "Employees can create their attendance"
ON public.attendance FOR INSERT
WITH CHECK (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Employees can update their attendance"
ON public.attendance FOR UPDATE
USING (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
);

-- RLS Policies for leaves
CREATE POLICY "Employees can view their own leaves"
ON public.leaves FOR SELECT
USING (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
);

CREATE POLICY "HR can view all company leaves"
ON public.leaves FOR SELECT
USING (
  public.has_role(auth.uid(), 'hr_manager') 
  OR public.has_role(auth.uid(), 'company_admin')
);

CREATE POLICY "Employees can create leave requests"
ON public.leaves FOR INSERT
WITH CHECK (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
);

CREATE POLICY "HR can manage leaves"
ON public.leaves FOR UPDATE
USING (
  public.has_role(auth.uid(), 'hr_manager') 
  OR public.has_role(auth.uid(), 'company_admin')
);

-- RLS Policies for documents
CREATE POLICY "Employees can view their documents"
ON public.documents FOR SELECT
USING (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
  OR public.has_role(auth.uid(), 'hr_manager')
  OR public.has_role(auth.uid(), 'company_admin')
);

CREATE POLICY "HR can manage documents"
ON public.documents FOR ALL
USING (
  public.has_role(auth.uid(), 'hr_manager')
  OR public.has_role(auth.uid(), 'company_admin')
);

-- RLS Policies for payslips
CREATE POLICY "Employees can view their payslips"
ON public.payslips FOR SELECT
USING (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
  OR public.has_role(auth.uid(), 'hr_manager')
  OR public.has_role(auth.uid(), 'company_admin')
);

CREATE POLICY "HR can manage payslips"
ON public.payslips FOR ALL
USING (
  public.has_role(auth.uid(), 'hr_manager')
  OR public.has_role(auth.uid(), 'company_admin')
);

-- RLS Policies for projects
CREATE POLICY "Users can view company projects"
ON public.projects FOR SELECT
USING (company_id = public.get_user_company(auth.uid()));

CREATE POLICY "Admins can manage projects"
ON public.projects FOR ALL
USING (
  public.has_role(auth.uid(), 'company_admin')
  OR public.has_role(auth.uid(), 'super_admin')
);

-- RLS Policies for project_assignments
CREATE POLICY "Users can view project assignments"
ON public.project_assignments FOR SELECT
USING (
  employee_id IN (
    SELECT id FROM public.employees WHERE user_id = auth.uid()
  )
  OR public.has_role(auth.uid(), 'hr_manager')
  OR public.has_role(auth.uid(), 'company_admin')
);

CREATE POLICY "Admins can manage project assignments"
ON public.project_assignments FOR ALL
USING (
  public.has_role(auth.uid(), 'company_admin')
  OR public.has_role(auth.uid(), 'hr_manager')
);

-- RLS Policies for assets
CREATE POLICY "Users can view company assets"
ON public.assets FOR SELECT
USING (company_id = public.get_user_company(auth.uid()));

CREATE POLICY "Admins can manage assets"
ON public.assets FOR ALL
USING (
  public.has_role(auth.uid(), 'company_admin')
  OR public.has_role(auth.uid(), 'hr_manager')
);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON public.companies
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON public.branches
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON public.employees
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_attendance_updated_at BEFORE UPDATE ON public.attendance
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_leaves_updated_at BEFORE UPDATE ON public.leaves
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON public.projects
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON public.assets
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Function to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name, last_name, email)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to calculate working hours
CREATE OR REPLACE FUNCTION public.calculate_working_hours()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sign_in IS NOT NULL AND NEW.sign_out IS NOT NULL THEN
    NEW.working_hours := EXTRACT(EPOCH FROM (NEW.sign_out::time - NEW.sign_in::time)) / 3600;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_attendance_hours
BEFORE INSERT OR UPDATE ON public.attendance
FOR EACH ROW EXECUTE FUNCTION public.calculate_working_hours();