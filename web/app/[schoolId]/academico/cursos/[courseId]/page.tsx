import SchoolPageHeader from "@/components/layout/school/SchoolPageHeader";
import PageHeading from "@/components/shared/PageHeading";
import { ScrollArea } from "@/components/ui/scroll-area";
import { courseRepository } from "@/features/academic/data/repositories";
import { studentRepository } from "@/features/students/data/repositories";
import DeleteCourseButton from "@/features/academic/presentation/components/course/DeleteCourseButton";
import EditCourseButton from "@/features/academic/presentation/components/course/EditCourseButton";
import StudentListItemCard from "@/features/students/presentation/components/StudentListItemCard";
import RegisterStudentButton from "@/features/students/presentation/components/RegisterStudentButton";
import GenerateStudentInviteCodesButton from "@/features/students/presentation/components/GenerateStudentInviteCodesButton";
import StudentSearchForm from "@/features/students/presentation/components/StudentSearchForm";
import { AccentCard } from "@/features/shared/components/cards/AccentCard";
import IndicatorsSummaryCard from "@/features/shared/components/cards/IndicatorsSummaryCard";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";
import AppPagination from "@/features/shared/components/navigation/AppPagination";
import SelectableChips from "@/features/shared/components/ui/SelectableChips";

export default async function CourseDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ schoolId: string; courseId: string }>;
  searchParams: Promise<{ studentPage?: string; studentSearch?: string }>;
}) {
  const { schoolId, courseId } = await params;
  const filters = await searchParams;
  const studentPage = Number(filters.studentPage ?? "1");
  const safeStudentPage = Number.isNaN(studentPage) ? 1 : studentPage;
  const studentSearch = (filters.studentSearch ?? "").trim();

  const response = await courseRepository.getCourseById(schoolId, courseId);
  if (!response.ok) {
    throw new Error(response.errors[0] ?? "Error al obtener el detalle del curso.");
  }

  const course = response.data;
  const formOptionsResponse = await courseRepository.getCourseFormOptions(schoolId);
  if (!formOptionsResponse.ok) {
    throw new Error(formOptionsResponse.errors[0] ?? "Error al obtener opciones de curso.");
  }
  const formOptions = formOptionsResponse.data;

  const studentsResponse = await studentRepository.getStudentsByCourse(
    schoolId,
    courseId,
    safeStudentPage,
    8,
    studentSearch,
  );
  if (!studentsResponse.ok) {
    throw new Error(studentsResponse.errors[0] ?? "Error al obtener los estudiantes del curso.");
  }
  const studentsData = studentsResponse.data;

  return (
    <>
      <SchoolPageHeader section="Academico" page="Curso" />
      <ContentGridSurface variant="diagonal">
        <PageHeading
          title={course.name}
          description={`Nivel: ${course.levelName}`}
          tone="light"
          returnHref={`/${schoolId}/academico/cursos`}
          returnLabel="Volver a cursos"
        />

        <section className="grid items-start gap-4 xl:grid-cols-[30%_70%]">
          <div className="space-y-4">
            <AccentCard variant="base" eyebrow="Gestion del curso" className="flex h-[420px] flex-col p-5">
              <div className="flex h-full flex-col gap-4">
                <p className="text-xs text-[#4e7399]">Materias vinculadas</p>

                <div className="min-h-[220px]">
                  <ScrollArea className="h-full pr-2">
                  {course.subjectNames.length ? (
                    <SelectableChips
                      options={course.subjectNames.map((subjectName) => ({
                        value: subjectName,
                        label: subjectName,
                      }))}
                      selectedValues={course.subjectNames}
                      readOnly
                    />
                  ) : (
                    <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] px-3 py-2 text-sm text-[#52749a]">
                      Este curso no tiene materias vinculadas.
                    </div>
                  )}
                  </ScrollArea>
                </div>

                <div className="mt-auto grid gap-2 sm:grid-cols-2">
                  <EditCourseButton
                    schoolId={schoolId}
                    course={course}
                    formOptions={formOptions}
                    variant="full"
                  />
                  <DeleteCourseButton
                    schoolId={schoolId}
                    courseId={course.id}
                    courseName={course.name}
                    variant="full"
                  />
                </div>
              </div>
            </AccentCard>

            <IndicatorsSummaryCard
              eyebrow="Indicadores"
              title="Resumen"
              description="Metricas generales del curso."
              items={[
                { label: "Estudiantes", value: "--" },
                { label: "Cursos", value: "--" },
              ]}
            />
          </div>

          <div className="space-y-4">
            <AccentCard variant="softBlue" eyebrow="Acciones" className="p-4">
              <div className="flex flex-wrap gap-2">
                <RegisterStudentButton schoolId={schoolId} courseId={courseId} />
                <GenerateStudentInviteCodesButton schoolId={schoolId} courseId={courseId} />
                <button
                  type="button"
                  className="h-10 rounded-lg bg-[#3f5f83] px-4 text-sm hover:bg-[#355170] opacity-80"
                  disabled
                >
                  Importar estudiantes
                </button>
              </div>
            </AccentCard>

            <AccentCard variant="base" eyebrow="Listado de Estudiantes" className="min-h-[420px] p-5">

              <StudentSearchForm
                basePath={`/${schoolId}/academico/cursos/${courseId}`}
                defaultSearch={studentSearch}
              />

              <ScrollArea className="h-[320px] pr-3">
                <div className="space-y-3 pb-1">
                  {studentsData.students.length ? (
                    studentsData.students.map((student) => (
                      <StudentListItemCard
                        key={student.id}
                        schoolId={schoolId}
                        courseId={courseId}
                        student={student}
                      />
                    ))
                  ) : (
                    <div className="rounded-xl border border-[#d5e3f3] bg-[#f8fbff] p-4 text-sm text-[#52749a]">
                      No hay estudiantes vinculados a este curso.
                    </div>
                  )}
                </div>
              </ScrollArea>

              <AppPagination
                page={studentsData.page}
                totalPages={studentsData.totalPages}
                basePath={`/${schoolId}/academico/cursos/${courseId}`}
                pageParamName="studentPage"
                hasPrev={studentsData.hasPrev}
                hasNext={studentsData.hasNext}
                query={{ studentSearch }}
              />
            </AccentCard>
          </div>
        </section>
      </ContentGridSurface>
    </>
  );
}
