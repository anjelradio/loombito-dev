import { toast } from "sonner";

const DEFAULT_ERROR_MESSAGE = "Ocurrió un error inesperado";

export function showErrorList(messages?: string[]) {
  if (!messages || messages.length === 0) {
    toast.error(DEFAULT_ERROR_MESSAGE);
    return;
  }

  const uniqueMessages = [...new Set(messages.filter(Boolean))];
  uniqueMessages.forEach((message) => toast.error(message));
}

export const appToast = {
  success: (message: string) => toast.success(message),
  error: (message: string) => toast.error(message),
  info: (message: string) => toast.info(message),
  warning: (message: string) => toast.warning(message),
  loading: (message: string) => toast.loading(message),
  dismiss: (id?: string | number) => toast.dismiss(id),
};
