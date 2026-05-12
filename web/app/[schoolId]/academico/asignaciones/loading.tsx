import SchoolPageHeaderSkeleton from "@/components/layout/school/SchoolPageHeaderSkeleton";
import { Skeleton } from "@/components/ui/skeleton";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default function AcademicAssignmentsLoading() {
  return (
    <>
      <SchoolPageHeaderSkeleton />

      <ContentGridSurface variant="mist">
        <div>
          <Skeleton className="h-10 w-64 bg-[#d4e3f3]" />
          <Skeleton className="mt-3 h-4 w-full max-w-3xl bg-[#dce9f6]" />
        </div>

        <section className="grid items-stretch gap-4 2xl:grid-cols-[70%_30%]">
          <div className="rounded-2xl border border-[#d8e5f5] bg-white p-6">
            <Skeleton className="h-12 w-full rounded-xl bg-[#dbe8f5]" />
            <Skeleton className="mt-4 h-[430px] w-full rounded-2xl bg-[#dbe8f5]" />
            <div className="mt-4 flex justify-center gap-2">
              <Skeleton className="h-9 w-9 rounded-lg bg-[#dbe8f5]" />
              <Skeleton className="h-9 w-9 rounded-lg bg-[#dbe8f5]" />
              <Skeleton className="h-9 w-9 rounded-lg bg-[#dbe8f5]" />
            </div>
          </div>

          <div className="flex min-w-0 flex-col gap-4">
            <div className="rounded-2xl border border-[#d8e5f5] bg-white p-5">
              <Skeleton className="h-40 w-full rounded-2xl bg-[#dbe8f5]" />
            </div>
            <div className="rounded-2xl border border-[#d8e5f5] bg-white p-5">
              <Skeleton className="h-40 w-full rounded-2xl bg-[#dbe8f5]" />
            </div>
          </div>
        </section>
      </ContentGridSurface>
    </>
  );
}
