"use client"
import { BookAIcon, School, Users } from "lucide-react";

const academicNavigation = {
  title: "Académico",
  url: "#",
  icon: <BookAIcon />,
  isActive: true,
  items: [
    { title: "Materias", url: "academico/materias" },
    { title: "Cursos", url: "academico/cursos" },
    { title: "Asignaciones", url: "academico/asignaciones" },
    { title: "Periodos y ponderacion", url: "academico/periodos-ponderacion" },
    { title: "Promedios", url: "academico/promedios" },
  ],
};

const reportsNavigation = {
  title: "Reportes",
  url: "#",
  icon: <BookAIcon />,
  isActive: true,
  items: [
    { title: "Asistencias", url: "academico/reportes/asistencias" },
    { title: "Evaluaciones", url: "academico/reportes/evaluaciones" },
    { title: "Boletines", url: "academico/reportes/boletines" },
  ],
};

const paymentsNavigation = {
  title: "Pagos",
  url: "#",
  icon: <BookAIcon />,
  isActive: true,
  items: [
    { title: "Conceptos de pago", url: "pagos/conceptos" },
    { title: "Deudas y Pagos", url: "pagos/deudas" },
  ],
};

export const navigationByRole = {
  owner: [
    {
      title: "Gestión del Colegio",
      url: "#",
      icon: <School />,
      isActive: true,
      items: [
        { title: "Información", url: "inicio/" },
        { title: "Configuración", url: "#" },
      ],
    },
    {
      title: "Usuarios",
      url: "#",
      icon: <Users />,
      isActive: true,
      items: [
        { title: "Administradores", url: "usuarios/administradores" },
        { title: "Profesores", url: "usuarios/profesores" },
        { title: "Invitaciones", url: "usuarios/invitar" },
      ],
    },
    academicNavigation,
    reportsNavigation,
    paymentsNavigation,
  ],

  admin: [
    academicNavigation,
    reportsNavigation,
    paymentsNavigation,
  ],

  teacher: [
    {
      title: "Docente",
      url: "#",
      icon: <School />,
      isActive: true,
      items: [
        { title: "Evaluaciones", url: "docente/evaluaciones" },
        { title: "Asistencias", url: "docente/asistencias" },
        { title: "Promedios", url: "docente/promedios" },
        { title: "Comunicados", url: "docente/comunicados" },
      ],
    },
    {
      title: "Analiticas",
      url: "#",
      icon: <BookAIcon />,
      isActive: true,
      items: [{ title: "Clasificacion", url: "docente/analiticas/clasificacion" }],
    },
  ],
};

export const navigationForSuperAdmin = [
  {
    title: "Administracion",
    url: "#",
    icon: <School />,
    isActive: true,
    items: [
      { title: "Dashboard", url: "administracion" },
      { title: "Gestion de colegios", url: "administracion/colegios" },
      { title: "Bitacora del sistema", url: "administracion/bitacora" },
    ],
  },
];
