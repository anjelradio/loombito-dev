export interface PaymentConcept {
  id: string;
  school_id: string;
  name: string;
  amount: number;
  is_recurring: boolean;
  state: boolean;
}

export interface PaymentConceptCreate {
  name: string;
  amount: number;
  is_recurring?: boolean;
}

export interface PaymentConceptUpdate {
  name?: string;
  amount?: number;
  is_recurring?: boolean;
  state?: boolean;
}
