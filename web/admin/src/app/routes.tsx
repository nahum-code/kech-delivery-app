import { createBrowserRouter } from "react-router";
import { Layout } from "./components/Layout";
import { Dashboard } from "./pages/Dashboard";
import { OrdersMonitor } from "./pages/OrdersMonitor";
import { DriverApproval } from "./pages/DriverApproval";
import { RestaurantManagement } from "./pages/RestaurantManagement";
import { MenuManagement } from "./pages/MenuManagement";
import { Analytics } from "./pages/Analytics";
import { Users } from "./pages/Users";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: Dashboard },
      { path: "orders", Component: OrdersMonitor },
      { path: "drivers", Component: DriverApproval },
      { path: "restaurants", Component: RestaurantManagement },
      { path: "menus", Component: MenuManagement },
      { path: "analytics", Component: Analytics },
      { path: "users", Component: Users },
    ],
  },
]);