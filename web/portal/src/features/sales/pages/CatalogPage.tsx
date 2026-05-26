"use client";

import { useCallback, useEffect, useState } from "react";
import { Eye } from "lucide-react";
import { toast } from "sonner";

import {
  fetchRestaurantMenu,
  fetchRestaurants,
  type PublicMenuItem,
  type RestaurantRecord,
  type RestaurantMenuPayload,
} from "@/services/catalog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export function CatalogPage() {
  const [restaurants, setRestaurants] = useState<RestaurantRecord[]>([]);
  const [search, setSearch] = useState("");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [menu, setMenu] = useState<RestaurantMenuPayload | null>(null);
  const [loadingList, setLoadingList] = useState(true);
  const [loadingMenu, setLoadingMenu] = useState(false);

  const loadRestaurants = useCallback(async (term?: string) => {
    setLoadingList(true);
    try {
      const data = await fetchRestaurants(term);
      setRestaurants(data);
      if (data.length > 0 && selectedId == null) {
        setSelectedId(data[0].id);
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to load restaurants");
    } finally {
      setLoadingList(false);
    }
  }, [selectedId]);

  useEffect(() => {
    const handle = setTimeout(() => void loadRestaurants(search), 300);
    return () => clearTimeout(handle);
  }, [search, loadRestaurants]);

  useEffect(() => {
    if (selectedId == null) return;
    setLoadingMenu(true);
    void fetchRestaurantMenu(selectedId)
      .then(setMenu)
      .catch((e) => {
        setMenu(null);
        toast.error(e instanceof Error ? e.message : "Failed to load menu");
      })
      .finally(() => setLoadingMenu(false));
  }, [selectedId]);

  const menuRows: Array<PublicMenuItem & { category: string }> = [];
  for (const category of menu?.categories ?? []) {
    for (const item of category.items) {
      menuRows.push({ ...item, category: category.name });
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold sm:text-3xl">Restaurant catalog</h1>
        <p className="mt-1 text-gray-600">Read-only view for sales agents</p>
      </div>

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Restaurants</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="search">Search</Label>
              <Input
                id="search"
                className="mt-2"
                placeholder="Name, phone, address..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Items</TableHead>
                    <TableHead />
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loadingList ? (
                    <TableRow>
                      <TableCell colSpan={4}>Loading...</TableCell>
                    </TableRow>
                  ) : restaurants.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={4}>No restaurants found</TableCell>
                    </TableRow>
                  ) : (
                    restaurants.map((r) => (
                      <TableRow key={r.id}>
                        <TableCell className="font-medium">{r.name}</TableCell>
                        <TableCell>
                          <Badge variant="outline">{r.is_active ? "Active" : "Inactive"}</Badge>
                        </TableCell>
                        <TableCell>{r.menu_item_count}</TableCell>
                        <TableCell>
                          <Button
                            size="sm"
                            variant={selectedId === r.id ? "default" : "outline"}
                            onClick={() => setSelectedId(r.id)}
                          >
                            <Eye className="mr-1 h-4 w-4" />
                            Menu
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{menu?.restaurant_name ?? "Menu"}</CardTitle>
          </CardHeader>
          <CardContent className="overflow-x-auto">
            {loadingMenu ? (
              <p className="text-sm text-gray-500">Loading menu...</p>
            ) : menuRows.length === 0 ? (
              <p className="text-sm text-gray-500">No menu items for this restaurant.</p>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Item</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Price</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {menuRows.map((item) => (
                    <TableRow key={item.id}>
                      <TableCell>{item.name}</TableCell>
                      <TableCell>{item.category}</TableCell>
                      <TableCell>
                        {item.price} {item.currency}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
