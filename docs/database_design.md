# Database Design (MVP)

This document captures the **database design plan and deliverables** for the Kech Delivery App MVP.

The database schema is designed to satisfy the MVP workflows and policies in `README.md`, including:
- channel-based pricing (Customer vs Sales)
- admin-only cancellation
- driver approval + document uploads
- restaurant opening hours enforcement
- order-level financial snapshots: `delivery_fee`, `driver_payout`, `platform_fee`

## 1. Core Entities (MVP)

Primary entity list (extracted from MVP scope):
- See: `docs/data_model_overview.md`

## 2. Database Schema (PostgreSQL)

Complete table-by-table design including:
- enums/reference types
- tables + fields
- constraints + indexes
- snapshot strategy for orders and order items
- relationships summary
- workflow validation against Customer/Driver/Sales/Admin flows

See: `docs/database_schema_postgresql.md`

## 3. ER Diagram

The ER diagram is exported to:
- `docs/er_diagram.png`

Source of truth:
- **`docs/er_diagram.drawio`** is the authoritative ER diagram file.

Derived/secondary formats:
- `docs/er_diagram.png` is a rendered artifact used for quick viewing in Git.
  - Regenerate with: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/generate_er_diagram_png.ps1`
- `docs/er_diagram.mmd` is a Mermaid ER version for text-based review and discussions.
  - Keep it in sync with the draw.io diagram when relationships change.

