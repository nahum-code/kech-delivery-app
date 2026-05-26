"use client";

import { useEffect, useState } from "react";
import { toast } from "sonner";

import { modifyOrder, type OrderDetail, type OrderModifyPayload } from "@/services/orders";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

type OrderModifyDialogProps = {
  order: OrderDetail | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSaved: (order: OrderDetail) => void;
};

export function OrderModifyDialog({
  order,
  open,
  onOpenChange,
  onSaved,
}: OrderModifyDialogProps) {
  const [saving, setSaving] = useState(false);
  const [quantities, setQuantities] = useState<Record<number, string>>({});
  const [receiverName, setReceiverName] = useState("");
  const [phone, setPhone] = useState("");
  const [addressLine, setAddressLine] = useState("");
  const [landmark, setLandmark] = useState("");
  const [customerNote, setCustomerNote] = useState("");

  useEffect(() => {
    if (!open || order == null) {
      return;
    }
    const qtyMap: Record<number, string> = {};
    for (const item of order.items) {
      qtyMap[item.id] = String(item.quantity);
    }
    setQuantities(qtyMap);
    setReceiverName(order.delivery_address.receiver_name ?? "");
    setPhone(order.delivery_address.phone ?? "");
    setAddressLine(order.delivery_address.address_line ?? "");
    setLandmark(order.delivery_address.landmark ?? "");
    setCustomerNote(order.customer_note ?? "");
  }, [open, order]);

  const handleSave = async () => {
    if (order == null) return;

    const items = order.items
      .map((item) => ({
        menu_item_id: item.menu_item,
        quantity: Number.parseInt(quantities[item.id] ?? "0", 10),
      }))
      .filter((line) => line.quantity >= 1);

    if (items.length === 0) {
      toast.error("At least one item must have quantity 1 or more.");
      return;
    }

    const payload: OrderModifyPayload = {
      items,
      delivery_address: {
        receiver_name: receiverName.trim(),
        phone: phone.trim(),
        address_line: addressLine.trim(),
        landmark: landmark.trim(),
      },
      customer_note: customerNote,
    };

    setSaving(true);
    try {
      const updated = await modifyOrder(order.id, payload);
      toast.success("Order updated");
      onSaved(updated);
      onOpenChange(false);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to modify order");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Modify order {order?.reference}</DialogTitle>
        </DialogHeader>

        {order == null ? null : (
          <div className="space-y-5 py-2">
            <div className="space-y-3">
              <p className="text-sm font-medium text-gray-700">Items</p>
              {order.items.map((item) => (
                <div key={item.id} className="flex items-center justify-between gap-3">
                  <span className="text-sm flex-1">
                    {item.item_name}{" "}
                    <span className="text-gray-500">({item.unit_price} ETB)</span>
                  </span>
                  <div className="flex items-center gap-2">
                    <Label htmlFor={`qty-${item.id}`} className="sr-only">
                      Quantity
                    </Label>
                    <Input
                      id={`qty-${item.id}`}
                      type="number"
                      min={1}
                      className="w-20"
                      value={quantities[item.id] ?? ""}
                      onChange={(e) =>
                        setQuantities((prev) => ({ ...prev, [item.id]: e.target.value }))
                      }
                    />
                  </div>
                </div>
              ))}
            </div>

            <div className="space-y-3 border-t pt-4">
              <p className="text-sm font-medium text-gray-700">Delivery address</p>
              <div className="space-y-2">
                <Label htmlFor="receiver">Receiver name</Label>
                <Input
                  id="receiver"
                  value={receiverName}
                  onChange={(e) => setReceiverName(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="phone">Phone</Label>
                <Input id="phone" value={phone} onChange={(e) => setPhone(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="address">Address</Label>
                <Input
                  id="address"
                  value={addressLine}
                  onChange={(e) => setAddressLine(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="landmark">Landmark</Label>
                <Input
                  id="landmark"
                  value={landmark}
                  onChange={(e) => setLandmark(e.target.value)}
                />
              </div>
            </div>

            <div className="space-y-2 border-t pt-4">
              <Label htmlFor="note">Customer note</Label>
              <Textarea
                id="note"
                value={customerNote}
                onChange={(e) => setCustomerNote(e.target.value)}
                rows={3}
              />
            </div>
          </div>
        )}

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button
            className="bg-[#800020] hover:bg-[#600018]"
            disabled={saving || order == null}
            onClick={() => void handleSave()}
          >
            {saving ? "Saving…" : "Save changes"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
