import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { createSalesAgent } from "@/services/users";
import { useRouter } from "next/navigation";
import { CheckCircle2 } from "lucide-react";

interface CreateSalesAgentDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onCreated?: (created: {
    user_id: number;
    phone: string;
    name: string;
    role: string;
  }) => void;
  existingPhones?: string[];
}

export function CreateSalesAgentDialog({
  open,
  onOpenChange,
  onCreated,
  existingPhones = [],
}: CreateSalesAgentDialogProps) {
  const router = useRouter();
  const [name, setName] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [successOpen, setSuccessOpen] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [errors, setErrors] = useState<{
    name?: string;
    phone?: string;
    password?: string;
  }>({});

  const validateForm = () => {
    const newErrors: { name?: string; phone?: string; password?: string } = {};

    if (!name.trim()) {
      newErrors.name = "Name is required";
    }

    // Validate phone number (+<countrycode><number>)
    if (!phoneNumber) {
      newErrors.phone = "Phone number is required";
    } else if (!/^\+[1-9]\d{7,14}$/.test(phoneNumber.trim())) {
      newErrors.phone = "Invalid phone number format (e.g., +251983204356)";
    }

    // Validate password
    if (!password) {
      newErrors.password = "Password is required";
    } else if (password.length < 8) {
      newErrors.password = "Password must be at least 8 characters";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (loading) return;

    if (!validateForm()) {
      return;
    }

    setSubmitError(null);
    setLoading(true);

    try {
      const normalizedPhone = phoneNumber.trim();
      if (existingPhones.includes(normalizedPhone)) {
        setLoading(false);
        setSubmitError("User already exists");
        return;
      }

      const created = await createSalesAgent({
        phone: normalizedPhone,
        password,
        name: name.trim(),
      });
      setLoading(false);
      onCreated?.(created);
      setName("");
      setPhoneNumber("");
      setPassword("");
      setErrors({});
      onOpenChange(false);
      setSuccessOpen(true);
    } catch (error) {
      setLoading(false);
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
      if (message === "User already exists.") {
        setSubmitError("User already exists");
        return;
      }
      if (
        message.toLowerCase().includes("throttled") ||
        message.toLowerCase().includes("too many")
      ) {
        setSubmitError(
          "Too many attempts. Please wait a moment and try again.",
        );
        return;
      }
      setSubmitError(
        message === "Invalid credentials."
          ? "Unable to create sales agent. Please verify the phone number and password, then try again."
          : message || "Something went wrong. Please try again.",
      );
    }
  };

  const handleClose = () => {
    setPhoneNumber("");
    setPassword("");
    setErrors({});
    setSubmitError(null);
    onOpenChange(false);
  };

  return (
    <>
      <Dialog open={open} onOpenChange={handleClose}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Create Sales Agent</DialogTitle>
            <DialogDescription>
              Create a new sales agent account. The role will be automatically
              set to &quot;Sales Agent&quot;.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="name">Full name</Label>
              <Input
                id="name"
                placeholder="e.g. Sara Kebede"
                value={name}
                onChange={(e) => {
                  setName(e.target.value);
                  if (errors.name) setErrors({ ...errors, name: undefined });
                  if (submitError) setSubmitError(null);
                }}
                className={errors.name ? "border-red-500" : ""}
              />
              {errors.name && (
                <p className="text-sm text-red-500">{errors.name}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="phone">Phone Number</Label>
              <Input
                id="phone"
                placeholder="+251983204356"
                value={phoneNumber}
                onChange={(e) => {
                  setPhoneNumber(e.target.value);
                  if (errors.phone) setErrors({ ...errors, phone: undefined });
                  if (submitError) setSubmitError(null);
                }}
                className={errors.phone ? "border-red-500" : ""}
              />
              {errors.phone && (
                <p className="text-sm text-red-500">{errors.phone}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="Enter password (min. 8 characters)"
                value={password}
                onChange={(e) => {
                  setPassword(e.target.value);
                  if (errors.password)
                    setErrors({ ...errors, password: undefined });
                  if (submitError) setSubmitError(null);
                }}
                className={errors.password ? "border-red-500" : ""}
              />
              {errors.password && (
                <p className="text-sm text-red-500">{errors.password}</p>
              )}
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
                onClick={handleClose}
                disabled={loading}
              >
                Cancel
              </Button>
              <Button
                type="submit"
                className="bg-[#800020] hover:bg-[#600018]"
                disabled={loading}
              >
                {loading ? "Creating..." : "Create Sales Agent"}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>

      <Dialog open={successOpen} onOpenChange={setSuccessOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <div className="mx-auto mb-2 flex h-12 w-12 items-center justify-center rounded-full bg-green-100">
              <CheckCircle2 className="h-7 w-7 text-green-600" />
            </div>
            <DialogTitle className="text-center">
              Sales Agent Created
            </DialogTitle>
            <DialogDescription className="text-center">
              Sales agent successfully created. The account is ready for login.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              className="w-full bg-[#800020] hover:bg-[#600018]"
              onClick={() => setSuccessOpen(false)}
            >
              Done
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
