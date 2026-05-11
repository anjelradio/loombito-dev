import type { SubscriptionPlan } from "@/features/subscriptions/domain/entities/plan";

export const SUBSCRIPTION_PLAN_CATALOG: SubscriptionPlan[] = [
  {
    code: "free",
    name: "Esencial",
    priceLabel: "Bs 0",
    billingLabel: "Siempre gratis",
    description: "Comienza con lo necesario para organizar tu operacion academica diaria.",
    highlights: [
      "Acceso por roles y administracion inicial",
      "Gestion de cursos, materias y asignaciones",
      "Evaluaciones y asistencia en flujo completo",
      "Reportes base para seguimiento academico",
      "Onboarding guiado para tu primer ciclo",
    ],
    limitations: [
      "Sin modulos avanzados de IA",
      "Sin backups automaticos",
      "Sin reportes personalizados",
      "Sin pagos QR y conciliacion",
    ],
  },
  {
    code: "professional",
    name: "Profesional",
    priceLabel: "Bs 149",
    billingLabel: "Por mes",
    description: "Escala tu colegio con herramientas operativas para equipos academicos y administrativos.",
    highlights: [
      "Todo lo incluido en Esencial",
      "Boletines, notificaciones y citaciones",
      "Pagos QR con historial consolidado",
      "Reportes personalizados por curso",
      "Exportacion PDF y Excel",
      "Prediccion de rendimiento academico",
    ],
    limitations: [
      "Sin clustering de estudiantes",
      "Sin riesgo academico automatizado",
      "Sin IA documental avanzada",
    ],
    featured: true,
  },
  {
    code: "institutional",
    name: "Institucional",
    priceLabel: "Bs 299",
    billingLabel: "Por mes",
    description: "Lleva la gestion a nivel estrategico con analitica avanzada e inteligencia educativa.",
    highlights: [
      "Todo lo incluido en Profesional",
      "Riesgo academico asistido por IA",
      "Clustering de estudiantes",
      "IA Gemini para apoyo docente y directivo",
      "Backups automaticos",
      "Dashboard inteligente y soporte prioritario",
    ],
  },
];
