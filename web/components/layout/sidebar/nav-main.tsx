"use client";

import * as React from "react";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import {
  SidebarGroup,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarMenuSub,
  SidebarMenuSubButton,
  SidebarMenuSubItem,
} from "@/components/ui/sidebar";
import { useAppStore } from "@/features/shared/presentation/store/app-store";
import { ChevronRightIcon } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { navigationByRole, navigationForSuperAdmin } from "./nav-config";

export function NavMain() {
  const pathname = usePathname();
  const selectedSchool = useAppStore((s) => s.selectedSchool);
  const user = useAppStore((s) => s.user);
  const storePersist = (useAppStore as typeof useAppStore & {
    persist?: {
      hasHydrated: () => boolean;
      onFinishHydration: (callback: () => void) => () => void;
    };
  }).persist;
  const [isHydrated, setIsHydrated] = React.useState(
    storePersist ? storePersist.hasHydrated() : true,
  );

  React.useEffect(() => {
    if (!storePersist) {
      setIsHydrated(true);
      return;
    }

    setIsHydrated(storePersist.hasHydrated());
    const unsubscribe = storePersist.onFinishHydration(() => {
      setIsHydrated(true);
    });

    return unsubscribe;
  }, [storePersist]);

  if (!isHydrated) {
    return (
      <SidebarGroup>
        <SidebarGroupLabel className="uppercase tracking-[0.14em] text-[#8EA8C7]">Navegacion</SidebarGroupLabel>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton disabled>
              <span>Cargando navegación...</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarGroup>
    );
  }

  const isAdminSection = pathname.startsWith("/administracion");
  if (user?.isSuperAdmin && isAdminSection) {
    const items = navigationForSuperAdmin;
    return (
      <SidebarGroup>
        <SidebarGroupLabel className="uppercase tracking-[0.14em] text-[#8EA8C7]">Navegacion</SidebarGroupLabel>
        <SidebarMenu>
          {items.map((item) => (
            <Collapsible
              key={item.title}
              asChild
              defaultOpen={item.isActive}
              className="group/collapsible"
            >
              <SidebarMenuItem>
                <CollapsibleTrigger asChild>
                  <SidebarMenuButton
                    tooltip={item.title}
                    className="text-[#EAF2FF] hover:bg-[#21466C]/70 hover:text-white data-[state=open]:bg-[#21466C]/80"
                  >
                    {item.icon}
                    <span>{item.title}</span>
                    <ChevronRightIcon className="ml-auto transition-transform duration-200 group-data-[state=open]/collapsible:rotate-90" />
                  </SidebarMenuButton>
                </CollapsibleTrigger>
                <CollapsibleContent>
                  <SidebarMenuSub>
                    {item.items?.map((subItem) => {
                      const href = `/${subItem.url}`.replace(/\/{2,}/g, "/");
                      const isActive = pathname === href || pathname.startsWith(`${href}/`);

                      return (
                        <SidebarMenuSubItem key={subItem.title}>
                          <SidebarMenuSubButton
                            asChild
                            className={isActive ? "bg-[#3B82F6]/22 text-white" : "text-[#BFD0E5] hover:bg-[#21466C]/65 hover:text-white"}
                          >
                            <Link href={href}>
                              <span>{subItem.title}</span>
                            </Link>
                          </SidebarMenuSubButton>
                        </SidebarMenuSubItem>
                      );
                    })}
                  </SidebarMenuSub>
                </CollapsibleContent>
              </SidebarMenuItem>
            </Collapsible>
          ))}
        </SidebarMenu>
      </SidebarGroup>
    );
  }

  if (!selectedSchool) return null;
  const schoolId = selectedSchool.id;

  const role = selectedSchool?.role;
  if (!role) {
    return (
      <SidebarGroup>
        <SidebarGroupLabel className="uppercase tracking-[0.14em] text-[#8EA8C7]">Navegacion</SidebarGroupLabel>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton disabled>
              <span>Esta escuela no tiene rol asignado.</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarGroup>
    );
  }

  const items = [...(navigationByRole[role] || [])];
  return (
    <SidebarGroup>
      <SidebarGroupLabel className="uppercase tracking-[0.14em] text-[#8EA8C7]">Navegacion</SidebarGroupLabel>
      <SidebarMenu>
        {items.map((item) => (
          <Collapsible
            key={item.title}
            asChild
            defaultOpen={item.isActive}
            className="group/collapsible"
          >
            <SidebarMenuItem>
              <CollapsibleTrigger asChild>
                <SidebarMenuButton
                  tooltip={item.title}
                  className="text-[#EAF2FF] hover:bg-[#21466C]/70 hover:text-white data-[state=open]:bg-[#21466C]/80"
                >
                  {item.icon}
                  <span>{item.title}</span>
                  <ChevronRightIcon className="ml-auto transition-transform duration-200 group-data-[state=open]/collapsible:rotate-90" />
                </SidebarMenuButton>
              </CollapsibleTrigger>
              <CollapsibleContent>
                <SidebarMenuSub>
                    {item.items?.map((subItem) => {
                      const href = `/${schoolId}/${subItem.url}`.replace(/\/{2,}/g, "/");
                      const isActive = pathname === href || pathname.startsWith(`${href}/`);

                      return (
                      <SidebarMenuSubItem key={subItem.title}>
                        <SidebarMenuSubButton
                          asChild
                          className={isActive ? "bg-[#3B82F6]/22 text-white" : "text-[#BFD0E5] hover:bg-[#21466C]/65 hover:text-white"}
                        >
                          <Link href={href}>
                            <span>{subItem.title}</span>
                          </Link>
                        </SidebarMenuSubButton>
                      </SidebarMenuSubItem>
                    )})}
                </SidebarMenuSub>
              </CollapsibleContent>
            </SidebarMenuItem>
          </Collapsible>
        ))}
      </SidebarMenu>
    </SidebarGroup>
  );
}
