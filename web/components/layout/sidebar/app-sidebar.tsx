import * as React from "react";

import { NavMain } from "@/components/layout/sidebar/nav-main";
import { NavProjects } from "@/components/layout/sidebar/nav-projects";
import { NavSecondary } from "@/components/layout/sidebar/nav-secondary";
import { NavUser } from "@/components/layout/sidebar/nav-user";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
} from "@/components/ui/sidebar";
import { FrameIcon, LifeBuoyIcon, MapIcon, PieChartIcon, SendIcon } from "lucide-react";
import { SchoolSwitcher } from "./school-switcher";
import { schoolRepository } from "@/features/school/data/repositories/school.repository";

const data = {
  navSecondary: [
    {
      title: "Soporte",
      url: "#",
      icon: <LifeBuoyIcon />,
    },
    {
      title: "Feedback",
      url: "#",
      icon: <SendIcon />,
    },
  ],
  projects: [
    {
      name: "Reportes",
      url: "#",
      icon: <FrameIcon />,
    },
    {
      name: "Proximamente",
      url: "#",
      icon: <PieChartIcon />,
    },
    {
      name: "Proximamente.",
      url: "#",
      icon: <MapIcon />,
    },
  ],
  
};

export async function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const response = await schoolRepository.getSchoolsByUser();
  const schools = response.ok && "data" in response && response.data ? response.data : [];
  return (
    <Sidebar variant="inset" {...props}>
      <SidebarHeader className="border-b border-[#2A4F75]/45 pb-3">
        <SchoolSwitcher schools={schools} />
      </SidebarHeader>
      <SidebarContent className="pt-2">
        <NavMain />
        <NavProjects projects={data.projects} />
        <NavSecondary items={data.navSecondary} className="mt-auto" />
      </SidebarContent>
      <SidebarFooter className="border-t border-[#2A4F75]/45">
        <NavUser />
      </SidebarFooter>
    </Sidebar>
  );
}
