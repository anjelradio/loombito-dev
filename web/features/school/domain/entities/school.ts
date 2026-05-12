export type SchoolRole = "owner" | "teacher" | "admin";
export type SchoolType = "public" | "private" | "charter";

export type School = {
  id: string;
  name: string;
  logoImage: string | null;
  type: SchoolType;
  phone: string;
  role?: SchoolRole;
};

export type SchoolDirectoryList = {
  schools: School[];
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
  hasPrev: boolean;
  hasNext: boolean;
};
