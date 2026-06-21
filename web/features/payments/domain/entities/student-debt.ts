export type DebtStatus = "PENDING" | "PAID" | "OVERDUE" | "CANCELLED";

export interface StudentDebt {
  id: string;
  student_id: string;
  concept_id: string;
  concept_name: string;
  amount: number;
  status: DebtStatus;
  due_date: string | null;
  billing_month: number | null;
  billing_year: number | null;
  state: boolean;
}
