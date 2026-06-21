export interface StudentPayment {
  id: string;
  student_debt_id: string;
  concept_name: string;
  amount_paid: number;
  transaction_id: string | null;
  payment_date: string;
}
