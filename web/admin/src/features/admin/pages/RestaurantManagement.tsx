"use client";

import { useState } from "react";
import { format } from "date-fns";
import { Edit, Eye, MapPin, Plus, Search, Trash2 } from "lucide-react";
import { toast } from "sonner";

import { useRestaurants } from "@/hooks/use-restaurants";
import type { RestaurantRecord } from "@/services/restaurants";
import { Badge } from "../components/ui/badge";
import { Button } from "../components/ui/button";
import { Card, CardContent } from "../components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "../components/ui/dialog";
import { Input } from "../components/ui/input";
import { Label } from "../components/ui/label";
import { Switch } from "../components/ui/switch";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../components/ui/table";

type FormState = {
  name: string;
  phone: string;
  address_text: string;
  latitude: string;
  longitude: string;
  opening_hours: string;
  is_active: boolean;
  description: string;
  logo: File | null;
  cover_image: File | null;
};

const emptyForm = (): FormState => ({
  name: "",
  phone: "",
  address_text: "",
  latitude: "31.6295",
  longitude: "-7.9811",
  opening_hours: "09:00 - 22:00",
  is_active: true,
  description: "",
  logo: null,
  cover_image: null,
});

function toForm(r?: RestaurantRecord | null): FormState {
  if (!r) return emptyForm();
  return {
    name: r.name,
    phone: r.phone,
    address_text: r.address_text,
    latitude: r.latitude,
    longitude: r.longitude,
    opening_hours: r.opening_hours,
    is_active: r.is_active,
    description: r.description,
    logo: null,
    cover_image: null,
  };
}

export function RestaurantManagement() {
  const { restaurants, loading, error, search, setSearch, save, remove } = useRestaurants();
  const [view, setView] = useState<RestaurantRecord | null>(null);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState<FormState>(emptyForm());
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const dialogOpen = creating || editingId != null;

  const closeDialog = () => {
    setCreating(false);
    setEditingId(null);
    setFormError(null);
  };

  const openCreate = () => {
    setForm(emptyForm());
    setEditingId(null);
    setCreating(true);
    setFormError(null);
  };

  const openEdit = (r: RestaurantRecord) => {
    setForm(toForm(r));
    setEditingId(r.id);
    setCreating(false);
    setView(null);
    setFormError(null);
  };

  const submit = async () => {
    if (!form.name.trim()) {
      const message = "Restaurant name is required";
      setFormError(message);
      toast.error(message);
      return;
    }
    setSaving(true);
    setFormError(null);
    try {
      await save(
        {
          name: form.name.trim(),
          phone: form.phone,
          address_text: form.address_text,
          latitude: form.latitude,
          longitude: form.longitude,
          opening_hours: form.opening_hours,
          is_active: form.is_active,
          description: form.description,
          logo: form.logo,
          cover_image: form.cover_image,
        },
        editingId ?? undefined,
      );
      toast.success(editingId ? "Restaurant updated" : "Restaurant created");
      closeDialog();
    } catch (e) {
      const message =
        e instanceof Error
          ? e.message.includes("403") || e.message.toLowerCase().includes("permission")
            ? "Only admin accounts can create or edit restaurants. Sign in with an admin user."
            : e.message
          : "Save failed";
      setFormError(message);
      toast.error(message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900 sm:text-3xl">Restaurant Management</h1>
          <p className="mt-1 text-gray-600">Manage restaurant partners and their information</p>
        </div>
        <Button className="shrink-0 bg-[#800020] hover:bg-[#600018]" onClick={openCreate}>
          <Plus className="mr-2 h-4 w-4" />
          Add Restaurant
        </Button>
      </div>

      <Card>
        <CardContent className="p-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <Input
              placeholder="Search restaurants..."
              className="pl-10"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </CardContent>
      </Card>

      {error && (
        <Card>
          <CardContent className="p-4 text-sm text-red-600">{error}</CardContent>
        </Card>
      )}

      <Card>
        <CardContent className="overflow-x-auto p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead className="hidden md:table-cell">Phone</TableHead>
                <TableHead>Location</TableHead>
                <TableHead className="hidden lg:table-cell">Hours</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="hidden sm:table-cell">Menu</TableHead>
                <TableHead className="hidden xl:table-cell">Updated</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={8} className="py-8 text-center text-gray-500">
                    Loading restaurants...
                  </TableCell>
                </TableRow>
              ) : restaurants.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="py-8 text-center text-gray-500">
                    No restaurants found
                  </TableCell>
                </TableRow>
              ) : (
                restaurants.map((r) => (
                  <TableRow key={r.id}>
                    <TableCell className="font-medium">{r.name}</TableCell>
                    <TableCell className="hidden md:table-cell">{r.phone || "-"}</TableCell>
                    <TableCell>
                      <div className="flex max-w-[200px] items-center gap-2">
                        <MapPin className="h-4 w-4 shrink-0 text-gray-400" />
                        <span className="truncate">{r.address_text || "-"}</span>
                      </div>
                    </TableCell>
                    <TableCell className="hidden lg:table-cell">{r.opening_hours || "-"}</TableCell>
                    <TableCell>
                      <Badge variant="outline" className={r.is_active ? "bg-green-100 text-green-700" : ""}>
                        {r.is_active ? "Active" : "Inactive"}
                      </Badge>
                    </TableCell>
                    <TableCell className="hidden sm:table-cell">{r.menu_item_count}</TableCell>
                    <TableCell className="hidden xl:table-cell">
                      {format(new Date(r.updated_at), "MMM dd, yyyy")}
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-1">
                        <Button variant="ghost" size="sm" onClick={() => setView(r)}>
                          <Eye className="h-4 w-4" />
                        </Button>
                        <Button variant="ghost" size="sm" onClick={() => openEdit(r)}>
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={async () => {
                            if (!confirm(`Delete ${r.name}?`)) return;
                            try {
                              await remove(r.id);
                              toast.success("Restaurant deleted");
                            } catch (e) {
                              toast.error(e instanceof Error ? e.message : "Delete failed");
                            }
                          }}
                        >
                          <Trash2 className="h-4 w-4 text-red-600" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={!!view} onOpenChange={() => setView(null)}>
        <DialogContent className="max-w-lg">
          {view && (
            <>
              <DialogHeader>
                <DialogTitle>{view.name}</DialogTitle>
                <DialogDescription>Restaurant details</DialogDescription>
              </DialogHeader>
              <div className="space-y-2 text-sm">
                <p>
                  <span className="text-gray-500">Phone:</span> {view.phone || "-"}
                </p>
                <p>
                  <span className="text-gray-500">Address:</span> {view.address_text}
                </p>
                <p>
                  <span className="text-gray-500">Hours:</span> {view.opening_hours}
                </p>
                <p>
                  <span className="text-gray-500">Menu items:</span> {view.menu_item_count}
                </p>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setView(null)}>
                  Close
                </Button>
                <Button className="bg-[#800020]" onClick={() => openEdit(view)}>
                  Edit
                </Button>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>

      <Dialog
        open={dialogOpen}
        onOpenChange={(open) => {
          if (!open && !saving) {
            closeDialog();
          }
        }}
      >
        <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editingId ? "Edit Restaurant" : "Add Restaurant"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div>
              <Label>Name</Label>
              <Input className="mt-2" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <Label>Phone</Label>
                <Input className="mt-2" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
              </div>
              <div>
                <Label>Opening hours</Label>
                <Input
                  className="mt-2"
                  value={form.opening_hours}
                  onChange={(e) => setForm({ ...form, opening_hours: e.target.value })}
                />
              </div>
            </div>
            <div>
              <Label>Address</Label>
              <Input
                className="mt-2"
                value={form.address_text}
                onChange={(e) => setForm({ ...form, address_text: e.target.value })}
              />
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <Label>Latitude</Label>
                <Input
                  className="mt-2"
                  value={form.latitude}
                  onChange={(e) => setForm({ ...form, latitude: e.target.value })}
                />
              </div>
              <div>
                <Label>Longitude</Label>
                <Input
                  className="mt-2"
                  value={form.longitude}
                  onChange={(e) => setForm({ ...form, longitude: e.target.value })}
                />
              </div>
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <Label>Logo</Label>
                <Input
                  type="file"
                  accept="image/*"
                  className="mt-2"
                  onChange={(e) => setForm({ ...form, logo: e.target.files?.[0] ?? null })}
                />
              </div>
              <div>
                <Label>Cover image</Label>
                <Input
                  type="file"
                  accept="image/*"
                  className="mt-2"
                  onChange={(e) => setForm({ ...form, cover_image: e.target.files?.[0] ?? null })}
                />
              </div>
            </div>
            <div>
              <Label>Description</Label>
              <Input
                className="mt-2"
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
              />
            </div>
            <div className="flex items-center justify-between rounded-lg border p-4">
              <Label>Active</Label>
              <Switch checked={form.is_active} onCheckedChange={(v) => setForm({ ...form, is_active: v })} />
            </div>
            {formError ? (
              <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700" role="alert">
                {formError}
              </p>
            ) : null}
          </div>
          <DialogFooter>
            <Button variant="outline" disabled={saving} onClick={closeDialog}>
              Cancel
            </Button>
            <Button className="bg-[#800020]" disabled={saving} onClick={() => void submit()}>
              {saving ? "Saving..." : "Save"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
