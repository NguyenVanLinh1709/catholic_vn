import { ParishInfoSection } from "./_sections/ParishInfoSection";
import { PriestsSection } from "./_sections/PriestsSection";
import { MassSchedulesSection } from "./_sections/MassSchedulesSection";

export default function AdminDashboard() {
  return (
    <div className="space-y-10">
      <ParishInfoSection />

      <hr className="border-gray-200 dark:border-gray-800" />

      <PriestsSection />

      <hr className="border-gray-200 dark:border-gray-800" />

      <MassSchedulesSection />
    </div>
  );
}
