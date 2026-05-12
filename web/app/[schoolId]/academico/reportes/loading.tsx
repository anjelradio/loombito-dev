import SchoolPageHeaderSkeleton from "@/components/layout/school/SchoolPageHeaderSkeleton";
import { Skeleton } from "@/components/ui/skeleton";

export default function ReportsLoading() {
  return (
    <>
      <SchoolPageHeaderSkeleton />
      <div className="space-y-5 p-4 md:p-6">
        <div className="rounded-2xl border border-[#d5e3f3] bg-white p-5">
          <Skeleton className="h-10 w-72 bg-[#d4e3f3]" />
          <Skeleton className="mt-3 h-4 w-full max-w-3xl bg-[#dce9f6]" />
        </div>
        <div className="grid gap-5 xl:grid-cols-[60%_40%]">
          <Skeleton className="h-[500px] w-full rounded-2xl bg-[#dbe8f5]" />
          <div className="space-y-5">
            <Skeleton className="h-60 w-full rounded-2xl bg-[#dbe8f5]" />
            <Skeleton className="h-52 w-full rounded-2xl bg-[#dbe8f5]" />
          </div>
        </div>
      </div>
    </>
  );
}
