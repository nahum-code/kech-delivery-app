import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "../components/ui/dialog";
import { Label } from "../components/ui/label";
import { Textarea } from "../components/ui/textarea";
import { Switch } from "../components/ui/switch";
import { Badge } from "../components/ui/badge";
import { mockCategories, mockMenuItems, Category, MenuItem } from "../data/mockData";
import { Plus, Edit, Eye, MoveUp, MoveDown, Image as ImageIcon } from "lucide-react";

export function MenuManagement() {
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(
    mockCategories[0]
  );
  const [selectedItem, setSelectedItem] = useState<MenuItem | null>(null);
  const [isEditingItem, setIsEditingItem] = useState(false);
  const [isCreatingItem, setIsCreatingItem] = useState(false);
  const [isEditingCategory, setIsEditingCategory] = useState(false);

  const filteredItems = selectedCategory
    ? mockMenuItems.filter((item) => item.category === selectedCategory.name)
    : mockMenuItems;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-gray-900">
            Menu Management
          </h1>
          <p className="text-gray-600 mt-1">
            Manage menu categories and items across all restaurants
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Categories Panel */}
        <Card className="lg:col-span-1">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>Categories</CardTitle>
              <Button
                size="sm"
                variant="outline"
                onClick={() => setIsEditingCategory(true)}
              >
                <Plus className="w-4 h-4 mr-1" />
                Add
              </Button>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="space-y-1 p-4">
              {mockCategories.map((category) => (
                <div
                  key={category.id}
                  className={`flex items-center justify-between p-3 rounded-lg cursor-pointer transition-colors ${
                    selectedCategory?.id === category.id
                      ? "bg-[#800020] text-white"
                      : "hover:bg-gray-100"
                  }`}
                  onClick={() => setSelectedCategory(category)}
                >
                  <div className="flex-1">
                    <p className="font-medium">{category.name}</p>
                    <p className={`text-xs ${
                      selectedCategory?.id === category.id
                        ? "text-white/70"
                        : "text-gray-500"
                    }`}>
                      {
                        mockMenuItems.filter((item) => item.category === category.name)
                          .length
                      }{" "}
                      items
                    </p>
                  </div>
                  <div className="flex gap-1">
                    <Button
                      variant="ghost"
                      size="sm"
                      className={
                        selectedCategory?.id === category.id
                          ? "hover:bg-white/20 text-white"
                          : ""
                      }
                    >
                      <MoveUp className="w-3 h-3" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      className={
                        selectedCategory?.id === category.id
                          ? "hover:bg-white/20 text-white"
                          : ""
                      }
                    >
                      <MoveDown className="w-3 h-3" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Menu Items Panel */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>
                {selectedCategory?.name || "All Items"} - Menu Items
              </CardTitle>
              <Button
                className="bg-[#800020] hover:bg-[#600018]"
                onClick={() => setIsCreatingItem(true)}
              >
                <Plus className="w-4 h-4 mr-2" />
                Add Item
              </Button>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Item</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredItems.map((item) => (
                  <TableRow key={item.id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 bg-gray-100 rounded-lg flex items-center justify-center">
                          <ImageIcon className="w-6 h-6 text-gray-400" />
                        </div>
                        <div>
                          <p className="font-medium">{item.name}</p>
                          <p className="text-sm text-gray-500 truncate max-w-xs">
                            {item.description}
                          </p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{item.category}</TableCell>
                    <TableCell className="font-medium">
                      {item.price} MAD
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant="outline"
                        className={
                          item.available
                            ? "bg-green-100 text-green-700"
                            : "bg-red-100 text-red-700"
                        }
                      >
                        {item.available ? "Available" : "Unavailable"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setSelectedItem(item)}
                        >
                          <Eye className="w-4 h-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => {
                            setSelectedItem(item);
                            setIsEditingItem(true);
                          }}
                        >
                          <Edit className="w-4 h-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      {/* View Item Dialog */}
      <Dialog
        open={!!selectedItem}
        onOpenChange={() => setSelectedItem(null)}
      >
        <DialogContent className="max-w-2xl">
          {selectedItem && (
            <>
              <DialogHeader>
                <DialogTitle>{selectedItem.name}</DialogTitle>
                <DialogDescription>
                  View menu item details and availability
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="w-full h-64 bg-gray-100 rounded-lg flex items-center justify-center">
                  <ImageIcon className="w-16 h-16 text-gray-400" />
                  <p className="text-gray-500 ml-3">Image preview</p>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label className="text-gray-600">Category</Label>
                    <p className="font-medium">{selectedItem.category}</p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Price</Label>
                    <p className="font-medium">{selectedItem.price} MAD</p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Availability</Label>
                    <div className="mt-1">
                      <Badge
                        variant="outline"
                        className={
                          selectedItem.available
                            ? "bg-green-100 text-green-700"
                            : "bg-red-100 text-red-700"
                        }
                      >
                        {selectedItem.available ? "Available" : "Unavailable"}
                      </Badge>
                    </div>
                  </div>
                </div>
                <div>
                  <Label className="text-gray-600">Description</Label>
                  <p className="mt-1">{selectedItem.description}</p>
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setSelectedItem(null)}>
                  Close
                </Button>
                <Button
                  className="bg-[#800020] hover:bg-[#600018]"
                  onClick={() => {
                    setIsEditingItem(true);
                  }}
                >
                  <Edit className="w-4 h-4 mr-2" />
                  Edit
                </Button>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* Edit/Create Item Dialog */}
      <Dialog
        open={isEditingItem || isCreatingItem}
        onOpenChange={(open) => {
          if (!open) {
            setIsEditingItem(false);
            setIsCreatingItem(false);
            setSelectedItem(null);
          }
        }}
      >
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>
              {isCreatingItem ? "Add New Menu Item" : "Edit Menu Item"}
            </DialogTitle>
            <DialogDescription>
              {isCreatingItem
                ? "Add a new item to the menu"
                : "Edit the details of the selected menu item"}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div>
              <Label>Item Name</Label>
              <Input
                defaultValue={selectedItem?.name}
                placeholder="Enter item name"
                className="mt-2"
              />
            </div>
            <div>
              <Label>Description</Label>
              <Textarea
                defaultValue={selectedItem?.description}
                placeholder="Describe the menu item..."
                className="mt-2"
                rows={3}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Category</Label>
                <Input
                  defaultValue={selectedItem?.category}
                  placeholder="Category"
                  className="mt-2"
                />
              </div>
              <div>
                <Label>Price (MAD)</Label>
                <Input
                  type="number"
                  defaultValue={selectedItem?.price}
                  placeholder="0"
                  className="mt-2"
                />
              </div>
            </div>
            <div>
              <Label>Item Image</Label>
              <div className="mt-2 border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                <ImageIcon className="w-12 h-12 text-gray-400 mx-auto" />
                <p className="text-sm text-gray-600 mt-2">
                  Click to upload or drag and drop
                </p>
                <p className="text-xs text-gray-500">PNG, JPG up to 10MB</p>
              </div>
            </div>
            <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
              <div>
                <Label>Availability</Label>
                <p className="text-sm text-gray-600">
                  Item is available for ordering
                </p>
              </div>
              <Switch defaultChecked={selectedItem?.available} />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setIsEditingItem(false);
                setIsCreatingItem(false);
                setSelectedItem(null);
              }}
            >
              Cancel
            </Button>
            <Button className="bg-[#800020] hover:bg-[#600018]">
              {isCreatingItem ? "Create Item" : "Save Changes"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Category Edit Dialog */}
      <Dialog open={isEditingCategory} onOpenChange={setIsEditingCategory}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add New Category</DialogTitle>
            <DialogDescription>
              Create a new menu category for organizing items
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div>
              <Label>Category Name</Label>
              <Input placeholder="Enter category name" className="mt-2" />
            </div>
            <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
              <div>
                <Label>Active</Label>
                <p className="text-sm text-gray-600">
                  Category is visible to customers
                </p>
              </div>
              <Switch defaultChecked />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsEditingCategory(false)}>
              Cancel
            </Button>
            <Button className="bg-[#800020] hover:bg-[#600018]">
              Create Category
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}