import { Skeleton } from "@/components/ui/skeleton";

export default function AuthLoading() {
  return (
    <div className="mx-auto w-full max-w-md space-y-4 p-6">
      <Skeleton className="h-10 w-40 bg-[#d4e3f3]" />
      <Skeleton className="h-4 w-full bg-[#dce9f6]" />
      <Skeleton className="h-56 w-full rounded-2xl bg-[#dbe8f5]" />
    </div>
  );
}
