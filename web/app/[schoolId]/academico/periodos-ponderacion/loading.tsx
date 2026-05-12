import SchoolPageHeaderSkeleton from "@/components/layout/school/SchoolPageHeaderSkeleton";
import { Skeleton } from "@/components/ui/skeleton";
import { ContentGridSurface } from "@/features/shared/components/layout/ContentGridSurface";

export default function TermsWeightsLoading() {
  return (
    <>
      <SchoolPageHeaderSkeleton />

      <ContentGridSurface variant="diagonal">
        <div>
          <Skeleton className="h-10 w-72 bg-[#d4e3f3]" />
          <Skeleton className="mt-3 h-4 w-full max-w-3xl bg-[#dce9f6]" />
        </div>

        <section className="grid gap-4 lg:grid-cols-2">
          <div className="space-y-4">
            <div className="rounded-2xl border border-[#d8e5f5] bg-white p-5">
              <Skeleton className="h-36 w-full rounded-2xl bg-[#dbe8f5]" />
            </div>
            <div className="rounded-2xl border border-[#d8e5f5] bg-white p-5">
              <Skeleton className="h-[430px] w-full rounded-2xl bg-[#dbe8f5]" />
            </div>
          </div>

          <div className="space-y-4">
            <div className="rounded-2xl border border-[#d8e5f5] bg-white p-5">
              <Skeleton className="h-[430px] w-full rounded-2xl bg-[#dbe8f5]" />
            </div>
            <div className="rounded-2xl border border-[#d8e5f5] bg-white p-5">
              <Skeleton className="h-36 w-full rounded-2xl bg-[#dbe8f5]" />
            </div>
          </div>
        </section>
      </ContentGridSurface>
    </>
  );
}
