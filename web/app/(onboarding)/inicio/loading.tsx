import { Skeleton } from "@/components/ui/skeleton";

export default function OnboardingLoading() {
  return (
    <div className="space-y-5 p-4 md:p-6">
      <div className="rounded-2xl border border-[#d5e3f3] bg-white p-5">
        <Skeleton className="h-10 w-60 bg-[#d4e3f3]" />
        <Skeleton className="mt-3 h-4 w-full max-w-2xl bg-[#dce9f6]" />
      </div>
      <div className="grid gap-5 md:grid-cols-2">
        <Skeleton className="h-64 w-full rounded-2xl bg-[#dbe8f5]" />
        <Skeleton className="h-64 w-full rounded-2xl bg-[#dbe8f5]" />
      </div>
    </div>
  );
}
