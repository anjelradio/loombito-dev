import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { AppSidebar } from "@/components/layout/sidebar/app-sidebar";
import { SchoolThemeBodyClass } from "@/components/layout/utils/SchoolThemeBodyClass";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";

export default async function AdministracionLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const cookieStore = await cookies();
  const token = cookieStore.get("access_token")?.value;
  if (!token) {
    redirect("/login");
  }

  return (
    <SidebarProvider className="school-theme">
      <SchoolThemeBodyClass />
      <AppSidebar />
      <SidebarInset className="school-inset relative overflow-hidden bg-transparent">
        <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_8%_12%,rgba(145,191,255,0.2),transparent_34%)]" />
        <div className="pointer-events-none absolute inset-0 bg-[linear-gradient(rgba(173,206,245,0.09)_1px,transparent_1px),linear-gradient(90deg,rgba(173,206,245,0.09)_1px,transparent_1px)] bg-[size:24px_24px]" />
        <div className="relative flex flex-1 flex-col">{children}</div>
      </SidebarInset>
    </SidebarProvider>
  );
}
