"use client";

import { useCallback, useEffect, useState } from "react";
import { Pencil, Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";

import {
  fetchRestaurants,
  type RestaurantRecord,
} from "@/services/restaurants";
import {
  createCategory,
  createMenuItem,
  deleteCategory,
  deleteMenuItem,
  fetchCategories,
  fetchMenuItems,
  type MenuCategoryRecord,
  type MenuItemRecord,
  updateCategory,
  updateMenuItem,
} from "@/services/menus";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export function MenuManagement() {
  const [restaurants, setRestaurants] = useState<RestaurantRecord[]>([]);
  const [restaurantId, setRestaurantId] = useState<number | null>(null);
  const [categories, setCategories] = useState<MenuCategoryRecord[]>([]);
  const [items, setItems] = useState<MenuItemRecord[]>([]);
  const [selectedCategoryId, setSelectedCategoryId] = useState<number | null>(
    null,
  );
  const [loading, setLoading] = useState(false);
  const [itemDialog, setItemDialog] = useState(false);
  const [editingItemId, setEditingItemId] = useState<number | null>(null);
  const [categoryDialog, setCategoryDialog] = useState(false);
  const [editingCategoryId, setEditingCategoryId] = useState<number | null>(
    null,
  );
  const [categoryForm, setCategoryForm] = useState({ name: "" });
  const [deleteCategoryTarget, setDeleteCategoryTarget] =
    useState<MenuCategoryRecord | null>(null);
  const [itemForm, setItemForm] = useState({
    name: "",
    description: "",
    price: "",
    takeaway_box_price: "",
    category_id: 0,
    is_available: true,
    image: null as File | null,
  });

  useEffect(() => {
    void fetchRestaurants().then((data) => {
      setRestaurants(data);
      if (data.length > 0) {
        setRestaurantId(data[0].id);
      }
    });
  }, []);

  const loadMenu = useCallback(async () => {
    if (restaurantId == null) return;
    setLoading(true);
    try {
      const [cats, menuItems] = await Promise.all([
        fetchCategories(restaurantId),
        fetchMenuItems(restaurantId),
      ]);
      setCategories(cats);
      setItems(menuItems);
      if (cats.length > 0 && selectedCategoryId == null) {
        setSelectedCategoryId(cats[0].id);
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to load menu");
    } finally {
      setLoading(false);
    }
  }, [restaurantId, selectedCategoryId]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void loadMenu();
  }, [loadMenu]);

  const filteredItems =
    selectedCategoryId != null
      ? items.filter((i) => i.category_id === selectedCategoryId)
      : items;

  const openCreateCategory = () => {
    setEditingCategoryId(null);
    setCategoryForm({ name: "" });
    setCategoryDialog(true);
  };

  const openEditCategory = (category: MenuCategoryRecord) => {
    setEditingCategoryId(category.id);
    setCategoryForm({ name: category.name });
    setCategoryDialog(true);
  };

  const saveCategory = async () => {
    if (restaurantId == null) return;
    const name = categoryForm.name.trim();
    if (!name) return;
    try {
      if (editingCategoryId != null) {
        await updateCategory(restaurantId, editingCategoryId, { name });
        toast.success("Category updated");
      } else {
        await createCategory(restaurantId, { name });
        toast.success("Category created");
      }
      setCategoryDialog(false);
      await loadMenu();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed");
    }
  };

  const deleteCategoryItemCount = items.filter(
    (i) => i.category_id === deleteCategoryTarget?.id,
  ).length;

  const confirmDeleteCategory = async () => {
    const target = deleteCategoryTarget;
    if (restaurantId == null || target == null) return;
    try {
      await deleteCategory(restaurantId, target.id);
      toast.success("Category deleted");
      if (selectedCategoryId === target.id) {
        setSelectedCategoryId(null);
      }
      setDeleteCategoryTarget(null);
      await loadMenu();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Delete failed");
    }
  };

  const openCreateItem = () => {
    setEditingItemId(null);
    setItemForm({
      name: "",
      description: "",
      price: "",
      takeaway_box_price: "",
      category_id: selectedCategoryId ?? categories[0]?.id ?? 0,
      is_available: true,
      image: null,
    });
    setItemDialog(true);
  };

  const openEditItem = (item: MenuItemRecord) => {
    setEditingItemId(item.id);
    setItemForm({
      name: item.name,
      description: item.description,
      price: item.price,
      takeaway_box_price: item.takeaway_box_price,
      category_id: item.category_id,
      is_available: item.is_available,
      image: null,
    });
    setItemDialog(true);
  };

  const saveItem = async () => {
    if (restaurantId == null) return;
    try {
      if (editingItemId != null) {
        await updateMenuItem(restaurantId, editingItemId, {
          category_id: itemForm.category_id,
          name: itemForm.name,
          description: itemForm.description,
          price: itemForm.price,
          takeaway_box_price: itemForm.takeaway_box_price || "0",
          is_available: itemForm.is_available,
          image: itemForm.image,
        });
        toast.success("Menu item updated");
      } else {
        await createMenuItem(restaurantId, {
          category_id: itemForm.category_id,
          name: itemForm.name,
          description: itemForm.description,
          price: itemForm.price,
          takeaway_box_price: itemForm.takeaway_box_price || "0",
          is_available: itemForm.is_available,
          image: itemForm.image,
        });
        toast.success("Menu item created");
      }
      setItemDialog(false);
      setEditingItemId(null);
      await loadMenu();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Save failed");
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold sm:text-3xl">
            Menu Management
          </h1>
          <p className="mt-1 text-gray-600">
            Categories and items per restaurant
          </p>
        </div>
        <div className="w-full sm:w-72">
          <Label>Restaurant</Label>
          <select
            className="mt-2 w-full rounded-md border border-gray-300 px-3 py-2 text-sm"
            value={restaurantId ?? ""}
            onChange={(e) => {
              setRestaurantId(Number(e.target.value));
              setSelectedCategoryId(null);
            }}
          >
            {restaurants.map((r) => (
              <option key={r.id} value={r.id}>
                {r.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-1">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Categories</CardTitle>
            <Button
              size="sm"
              variant="outline"
              onClick={() => openCreateCategory()}
            >
              <Plus className="h-4 w-4" />
            </Button>
          </CardHeader>
          <CardContent className="space-y-2">
            {categories.map((c) => (
              <div key={c.id} className="flex items-center gap-1">
                <button
                  type="button"
                  className={`min-w-0 flex-1 rounded-lg px-3 py-2 text-left text-sm ${
                    selectedCategoryId === c.id
                      ? "bg-[#800020] text-white"
                      : "bg-gray-100"
                  }`}
                  onClick={() => setSelectedCategoryId(c.id)}
                >
                  {c.name}
                </button>
                <Button
                  variant="ghost"
                  size="sm"
                  className="shrink-0"
                  onClick={() => openEditCategory(c)}
                >
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  className="shrink-0"
                  onClick={() => setDeleteCategoryTarget(c)}
                >
                  <Trash2 className="h-4 w-4 text-red-600" />
                </Button>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Menu items</CardTitle>
            <Button
              size="sm"
              className="bg-[#800020]"
              disabled={categories.length === 0}
              onClick={() => openCreateItem()}
            >
              <Plus className="mr-1 h-4 w-4" />
              Add item
            </Button>
          </CardHeader>
          <CardContent className="overflow-x-auto p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={4}>Loading...</TableCell>
                  </TableRow>
                ) : filteredItems.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4}>No items</TableCell>
                  </TableRow>
                ) : (
                  filteredItems.map((item) => (
                    <TableRow key={item.id}>
                      <TableCell className="font-medium">{item.name}</TableCell>
                      <TableCell>
                        {item.price} {item.currency}
                        {Number(item.takeaway_box_price) > 0 && (
                          <span className="block text-xs text-gray-500">
                            + {item.takeaway_box_price} {item.currency} box
                          </span>
                        )}
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline">
                          {item.is_available ? "Available" : "Off"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => openEditItem(item)}
                        >
                          <Pencil className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={async () => {
                            if (restaurantId == null) return;
                            try {
                              await updateMenuItem(restaurantId, item.id, {
                                is_available: !item.is_available,
                              });
                              await loadMenu();
                            } catch (e) {
                              toast.error(
                                e instanceof Error
                                  ? e.message
                                  : "Update failed",
                              );
                            }
                          }}
                        >
                          Toggle
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={async () => {
                            if (restaurantId == null) return;
                            try {
                              await deleteMenuItem(restaurantId, item.id);
                              await loadMenu();
                            } catch (e) {
                              toast.error(
                                e instanceof Error
                                  ? e.message
                                  : "Delete failed",
                              );
                            }
                          }}
                        >
                          <Trash2 className="h-4 w-4 text-red-600" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      <Dialog
        open={deleteCategoryTarget != null}
        onOpenChange={(open) => {
          if (!open) setDeleteCategoryTarget(null);
        }}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete category</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-600">
            Delete &quot;{deleteCategoryTarget?.name}&quot;? This also
            permanently removes {deleteCategoryItemCount} menu item
            {deleteCategoryItemCount === 1 ? "" : "s"} in this category. This
            action cannot be undone.
          </p>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDeleteCategoryTarget(null)}
            >
              Cancel
            </Button>
            <Button
              className="bg-red-600 hover:bg-red-700"
              onClick={() => void confirmDeleteCategory()}
            >
              Delete
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={categoryDialog} onOpenChange={setCategoryDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {editingCategoryId != null ? "Edit category" : "Add category"}
            </DialogTitle>
          </DialogHeader>
          <div>
            <Label>Name</Label>
            <Input
              value={categoryForm.name}
              onChange={(e) =>
                setCategoryForm({ ...categoryForm, name: e.target.value })
              }
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCategoryDialog(false)}>
              Cancel
            </Button>
            <Button className="bg-[#800020]" onClick={() => void saveCategory()}>
              Save
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog
        open={itemDialog}
        onOpenChange={(open) => {
          setItemDialog(open);
          if (!open) setEditingItemId(null);
        }}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {editingItemId != null ? "Edit menu item" : "Add menu item"}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-3">
            <div>
              <Label>Category</Label>
              <select
                className="mt-2 w-full rounded-md border border-gray-300 px-3 py-2 text-sm"
                value={itemForm.category_id}
                onChange={(e) =>
                  setItemForm({
                    ...itemForm,
                    category_id: Number(e.target.value),
                  })
                }
              >
                {categories.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <Label>Name</Label>
              <Input
                value={itemForm.name}
                onChange={(e) =>
                  setItemForm({ ...itemForm, name: e.target.value })
                }
              />
            </div>
            <div>
              <Label>Price (ETB)</Label>
              <Input
                value={itemForm.price}
                onChange={(e) =>
                  setItemForm({ ...itemForm, price: e.target.value })
                }
              />
            </div>
            <div>
              <Label>Takeaway box price (ETB)</Label>
              <Input
                inputMode="decimal"
                placeholder="0"
                value={itemForm.takeaway_box_price}
                onChange={(e) =>
                  setItemForm({
                    ...itemForm,
                    takeaway_box_price: e.target.value,
                  })
                }
              />
              <p className="mt-1 text-xs text-gray-500">
                Added on top of the item price for each unit ordered.
              </p>
            </div>
            <div>
              <Label>Description</Label>
              <Input
                value={itemForm.description}
                onChange={(e) =>
                  setItemForm({ ...itemForm, description: e.target.value })
                }
              />
            </div>
            <div>
              <Label>Image</Label>
              <Input
                type="file"
                accept="image/*"
                onChange={(e) =>
                  setItemForm({
                    ...itemForm,
                    image: e.target.files?.[0] ?? null,
                  })
                }
              />
            </div>
            <div className="flex items-center justify-between">
              <Label>Available</Label>
              <Switch
                checked={itemForm.is_available}
                onCheckedChange={(v) =>
                  setItemForm({ ...itemForm, is_available: v })
                }
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setItemDialog(false)}>
              Cancel
            </Button>
            <Button className="bg-[#800020]" onClick={() => void saveItem()}>
              Save
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
