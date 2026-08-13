# Wishlist Tracker - Design Plan & Prompts

This document outlines the design strategy, visual language, and structural prompts for the Wishlist Tracker application, based on the "Vibrant Finance" design system.

## 1. Visual Identity (Vibrant Finance)

- **Primary Color:** indigo-600 (#6366f1) - Used for primary actions, progress bars, and branding.
- **Backgrounds:** Light blue-gray surfaces (#f8f9ff) with clean white containers.
- **Typography:** Inter (Sans-serif) - Clean, modern, and highly legible for financial data.
- **Roundness:** 8px to 12px (Round Eight) for a friendly, modern feel.

## 2. Information Architecture

The app is structured into four main pillars:

1. **Home/Dashboard:** Summary of total progress and high-level wishlist cards.
2. **Wishlist List:** Management and filtering of saved items.
3. **Statistics:** Data visualization of saving trends and category distribution.
4. **Detail View:** Deep dive into specific items with calculators and history.

---

## 3. Screen Design Prompts

### Screen 1: Dashboard (Beranda)

**Prompt:**
Create a dashboard for a finance-focused wishlist app.

- **Header:** Personalized greeting "Halo, Albert!" with a notification bell and user profile.
- **Summary Section:** Three prominent cards:
  1. Total Items (Label: Wishlist)
  2. Total Amount Saved (Label: Terkumpul, with currency formatting)
  3. Total Goal Amount (Label: Target)
- **Search & Filter:** A clean search bar followed by category pills (Semua, Terbaru, Statistik).
- **Wishlist Grid:** Interactive cards featuring product images, category badges, goal dates, and a progress bar showing the percentage saved vs. target price.
- **Mobile Navigation:** Fixed bottom navigation bar with icons for Home, Wishlist, Stats, and Profile.

### Screen 2: Savings Statistics (Statistik)

**Prompt:**
Design a statistics page for tracking savings progress.

- **Highlight Card:** Display "Average Monthly Savings" with a percentage growth indicator (e.g., +15% from last month).
- **Trend Chart:** A large, smooth area line chart showing saving performance over the last 6 months.
- **Category Allocation:** A list or chart showing how savings are distributed across categories (e.g., Vehicles 50%, Electronics 30%, Others 20%) using themed progress bars.
- **CTA:** A button to generate a detailed performance report.

### Screen 3: Item Detail (Detail Wishlist)

**Prompt:**
Create a detailed view for a specific wishlist item (e.g., a high-end motorcycle).

- **Hero Image:** Large, high-quality product photo with a floating category tag.
- **Progress Visualization:** A central circular progress gauge showing the percentage saved.
- **Financial Breakdown:** Large display of current savings vs. target total.
- **Smart Recommendation Card:** A dedicated section that calculates the monthly savings needed to reach the goal by a specific date.
- **Transaction History:** A clean list of recent "Savings Deposits" with dates and status badges.
- **Action Button:** A prominent "Add Savings" floating button or fixed CTA.

### Screen 4: Add New Item (Tambah Wishlist Baru)

**Prompt:**
A clean form-based screen to add a new goal.

- **Image Upload:** A large, dashed-border upload zone for product photos.
- **Form Fields:** Input fields for Item Name, Category (Dropdown), Target Price (Currency input), and Target Date (Date picker).
- **Validation:** Clear labels and placeholder text like "Contoh: Laptop Baru".
- **Primary Action:** A full-width "Save Wishlist" button.

---

## 4. Design Principles

1. **Progress Transparency:** Always show how close the user is to their goal.
2. **Action-Oriented:** Make "Adding Savings" the most accessible action.
3. **Clean Data:** Use whitespace and clear typography to make financial numbers non-intimidating.
4. **User-Data Isolation:** Every account owns a private database partition (`wishlist_userId` / `savings_userId`) to prevent cross-account leaks.
5. **Progress History:** Savings history uses an `ExpansionTile` to avoid layout overload, limiting previews to 5 entries with a bottom sheet for all transactions. Money rows inside cards use flexible wrappers to prevent horizontal overflows.
