import { useState } from "react";
import { Card, CardContent } from "../components/ui/card";
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
import { Switch } from "../components/ui/switch";
import { Badge } from "../components/ui/badge";
import { mockRestaurants, Restaurant } from "../data/mockData";
import { Search, Plus, Edit, Eye, MapPin } from "lucide-react";
import { format } from "date-fns";

export function RestaurantManagement() {
  const [selectedRestaurant, setSelectedRestaurant] =
    useState<Restaurant | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [isCreating, setIsCreating] = useState(false);

  const handleEdit = (restaurant: Restaurant) => {
    setSelectedRestaurant(restaurant);
    setIsEditing(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-gray-900">
            Restaurant Management
          </h1>
          <p className="text-gray-600 mt-1">
            Manage restaurant partners and their information
          </p>
        </div>
        <Button
          className="bg-[#800020] hover:bg-[#600018]"
          onClick={() => setIsCreating(true)}
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Restaurant
        </Button>
      </div>

      {/* Search */}
      <Card>
        <CardContent className="p-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input
              placeholder="Search restaurants by name, location, or phone..."
              className="pl-10"
            />
          </div>
        </CardContent>
      </Card>

      {/* Restaurants Table */}
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Restaurant Name</TableHead>
                <TableHead>Phone</TableHead>
                <TableHead>Location</TableHead>
                <TableHead>Opening Hours</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Menu Items</TableHead>
                <TableHead>Last Updated</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {mockRestaurants.map((restaurant) => (
                <TableRow key={restaurant.id}>
                  <TableCell className="font-medium">
                    {restaurant.name}
                  </TableCell>
                  <TableCell>{restaurant.phone}</TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <MapPin className="w-4 h-4 text-gray-400" />
                      <span className="max-w-xs truncate">
                        {restaurant.location}
                      </span>
                    </div>
                  </TableCell>
                  <TableCell>{restaurant.openingHours}</TableCell>
                  <TableCell>
                    <Badge
                      variant="outline"
                      className={
                        restaurant.status === "Active"
                          ? "bg-green-100 text-green-700"
                          : "bg-gray-100 text-gray-700"
                      }
                    >
                      {restaurant.status}
                    </Badge>
                  </TableCell>
                  <TableCell>{restaurant.menuCount}</TableCell>
                  <TableCell>
                    {format(restaurant.lastUpdated, "MMM dd, yyyy")}
                  </TableCell>
                  <TableCell>
                    <div className="flex gap-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setSelectedRestaurant(restaurant)}
                      >
                        <Eye className="w-4 h-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleEdit(restaurant)}
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

      {/* View Restaurant Dialog */}
      <Dialog
        open={!!selectedRestaurant && !isEditing}
        onOpenChange={() => setSelectedRestaurant(null)}
      >
        <DialogContent className="max-w-2xl">
          {selectedRestaurant && (
            <>
              <DialogHeader>
                <DialogTitle>{selectedRestaurant.name}</DialogTitle>
                <DialogDescription>
                  View and manage restaurant details
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label className="text-gray-600">Phone</Label>
                    <p className="font-medium">{selectedRestaurant.phone}</p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Status</Label>
                    <div className="mt-1">
                      <Badge
                        variant="outline"
                        className={
                          selectedRestaurant.status === "Active"
                            ? "bg-green-100 text-green-700"
                            : "bg-gray-100 text-gray-700"
                        }
                      >
                        {selectedRestaurant.status}
                      </Badge>
                    </div>
                  </div>
                  <div className="col-span-2">
                    <Label className="text-gray-600">Location</Label>
                    <p className="font-medium">{selectedRestaurant.location}</p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Opening Hours</Label>
                    <p className="font-medium">
                      {selectedRestaurant.openingHours}
                    </p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Menu Items</Label>
                    <p className="font-medium">{selectedRestaurant.menuCount}</p>
                  </div>
                  <div className="col-span-2">
                    <Label className="text-gray-600">Last Updated</Label>
                    <p className="font-medium">
                      {format(selectedRestaurant.lastUpdated, "MMM dd, yyyy 'at' HH:mm")}
                    </p>
                  </div>
                </div>

                {/* Map Placeholder */}
                <div>
                  <Label>Location on Map</Label>
                  <div className="w-full h-48 bg-gray-100 rounded-lg mt-2 flex items-center justify-center">
                    <MapPin className="w-12 h-12 text-gray-400" />
                    <p className="text-gray-500 ml-2">Map view placeholder</p>
                  </div>
                </div>
              </div>
              <DialogFooter>
                <Button
                  variant="outline"
                  onClick={() => setSelectedRestaurant(null)}
                >
                  Close
                </Button>
                <Button
                  className="bg-[#800020] hover:bg-[#600018]"
                  onClick={() => handleEdit(selectedRestaurant)}
                >
                  <Edit className="w-4 h-4 mr-2" />
                  Edit
                </Button>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* Edit/Create Restaurant Dialog */}
      <Dialog
        open={isEditing || isCreating}
        onOpenChange={(open) => {
          if (!open) {
            setIsEditing(false);
            setIsCreating(false);
            setSelectedRestaurant(null);
          }
        }}
      >
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>
              {isCreating ? "Add New Restaurant" : "Edit Restaurant"}
            </DialogTitle>
            <DialogDescription>
              {isCreating
                ? "Add a new restaurant to your management system"
                : "Edit the details of the selected restaurant"}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div>
              <Label>Restaurant Name</Label>
              <Input
                defaultValue={selectedRestaurant?.name}
                placeholder="Enter restaurant name"
                className="mt-2"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Phone</Label>
                <Input
                  defaultValue={selectedRestaurant?.phone}
                  placeholder="+212 5 24 XX XX XX"
                  className="mt-2"
                />
              </div>
              <div>
                <Label>Opening Hours</Label>
                <Input
                  defaultValue={selectedRestaurant?.openingHours}
                  placeholder="09:00 - 22:00"
                  className="mt-2"
                />
              </div>
            </div>
            <div>
              <Label>Location Address</Label>
              <Input
                defaultValue={selectedRestaurant?.location}
                placeholder="Enter full address"
                className="mt-2"
              />
            </div>
            <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
              <div>
                <Label>Operational Status</Label>
                <p className="text-sm text-gray-600">
                  Restaurant is accepting orders
                </p>
              </div>
              <Switch defaultChecked={selectedRestaurant?.status === "Active"} />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setIsEditing(false);
                setIsCreating(false);
                setSelectedRestaurant(null);
              }}
            >
              Cancel
            </Button>
            <Button className="bg-[#800020] hover:bg-[#600018]">
              {isCreating ? "Create Restaurant" : "Save Changes"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}