import { redirect } from "next/navigation";
import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import { studentDebtRepository } from "@/features/payments/data/repositories/studentDebtRepository";
import { studentPaymentRepository } from "@/features/payments/data/repositories/studentPaymentRepository";
import { studentApi } from "@/features/students/data/api/student-api";
import StudentDebtsList from "@/features/payments/presentation/components/debts/StudentDebtsList";
import StudentPaymentsList from "@/features/payments/presentation/components/debts/StudentPaymentsList";

// Página servidor que carga deudas y pagos del estudiante en paralelo
export default async function StudentDebtsPage({
  params,
}: {
  params: Promise<{ schoolId: string; studentId: string }>;
}) {
  const { schoolId, studentId } = await params;

  // Get student info for the heading
  const studentRes = await studentApi.getStudentById(schoolId, studentId);
  if (!studentRes.ok) {
    throw new Error(studentRes.errors[0] ?? "Estudiante no encontrado");
  }
  const student = studentRes.data;

  // Get only pending debts
  const [debtsRes, paymentsRes] = await Promise.all([
    studentDebtRepository.getStudentDebts(schoolId, studentId, "PENDING"),
    studentPaymentRepository.getStudentPayments(schoolId, studentId),
  ]);

  if (!debtsRes.ok) {
    throw new Error(debtsRes.errors[0] ?? "Error al obtener las deudas");
  }
  if (!paymentsRes.ok) {
    throw new Error(paymentsRes.errors[0] ?? "Error al obtener los pagos");
  }
  
  const pendingDebts = debtsRes.data;
  const payments = paymentsRes.data;

  return (
    <>
      <SchoolPageHeader section="Pagos" page="Estado de cuenta" />

      <ContentGridSurface variant="north">
        <PageHeading
          title={`Estado de cuenta: ${student.firstName} ${student.lastName}`}
          description="Consulta todas las deudas pendientes y transacciones de este estudiante."
          tone="light"
          returnHref={`/${schoolId}/pagos/deudas`}
          returnLabel="Volver a la selección de estudiantes"
        />

        <section className="mt-6">
          <StudentDebtsList debts={pendingDebts} payments={payments} />
          <StudentPaymentsList payments={payments} />
        </section>
      </ContentGridSurface>
    </>
  );
}
