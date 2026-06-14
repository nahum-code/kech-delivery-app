import { useEffect, useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import { updateSalesAgent, type AdminUser } from "@/services/users";

type EditableStatus = "active" | "inactive";

interface EditSalesAgentDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  agent: AdminUser | null;
  onUpdated?: (updated: AdminUser) => void;
}

export function EditSalesAgentDialog({
  open,
  onOpenChange,
  agent,
  onUpdated,
}: EditSalesAgentDialogProps) {
  const router = useRouter();
  const [name, setName] = useState("");
  const [status, setStatus] = useState<EditableStatus>("active");
  const [loading, setLoading] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [nameError, setNameError] = useState<string | null>(null);

  useEffect(() => {
    if (open && agent) {
      setName(agent.name ?? "");
      setStatus(agent.status === "inactive" ? "inactive" : "active");
      setNameError(null);
      setSubmitError(null);
    }
  }, [open, agent]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (loading || !agent) return;

    const trimmedName = name.trim();
    if (!trimmedName) {
      setNameError("Name is required");
      return;
    }

    setSubmitError(null);
    setLoading(true);
    try {
      const updated = await updateSalesAgent(agent.user_id, {
        name: trimmedName,
        status,
      });
      onUpdated?.(updated);
      onOpenChange(false);
      toast.success("Sales agent updated");
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : "Something went wrong. Please try again.";
      if (message === "Session expired") {
        toast.error("Session expired");
        onOpenChange(false);
        router.replace("/login");
        return;
      }
      setSubmitError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Edit Sales Agent</DialogTitle>
          <DialogDescription>
            Update the sales agent&apos;s name and account status.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="edit-name">Full name</Label>
            <Input
              id="edit-name"
              placeholder="e.g. Sara Kebede"
              value={name}
              onChange={(e) => {
                setName(e.target.value);
                if (nameError) setNameError(null);
                if (submitError) setSubmitError(null);
              }}
              className={nameError ? "border-red-500" : ""}
            />
            {nameError && <p className="text-sm text-red-500">{nameError}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="edit-status">Status</Label>
            <Select
              value={status}
              onValueChange={(value) => setStatus(value as EditableStatus)}
            >
              <SelectTrigger id="edit-status">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="active">Active</SelectItem>
                <SelectItem value="inactive">Inactive</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {submitError && (
            <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
              {submitError}
            </p>
          )}

          <div className="flex gap-3 justify-end pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
              disabled={loading}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              className="bg-[#800020] hover:bg-[#600018]"
              disabled={loading}
            >
              {loading ? "Saving..." : "Save Changes"}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
