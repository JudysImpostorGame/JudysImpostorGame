import json
import tkinter as tk
from tkinter import messagebox

class InvoiceApp:
    def __init__(self, master):
        self.master = master
        master.title("Kfz Werkstatt Rechnung")

        self.customer_var = tk.StringVar()
        self.vehicle_var = tk.StringVar()
        self.items = []

        tk.Label(master, text="Kunde").grid(row=0, column=0, sticky="w")
        tk.Entry(master, textvariable=self.customer_var).grid(row=0, column=1, sticky="ew")

        tk.Label(master, text="Fahrzeug").grid(row=1, column=0, sticky="w")
        tk.Entry(master, textvariable=self.vehicle_var).grid(row=1, column=1, sticky="ew")

        tk.Label(master, text="Leistung / Material").grid(row=2, column=0, sticky="w")
        tk.Label(master, text="Preis").grid(row=2, column=1, sticky="w")

        self.items_frame = tk.Frame(master)
        self.items_frame.grid(row=3, column=0, columnspan=2, pady=(0,10))

        self.add_item_row()

        tk.Button(master, text="Weitere Position", command=self.add_item_row).grid(row=4, column=0)
        tk.Button(master, text="Rechnung speichern", command=self.save_invoice).grid(row=4, column=1)

        master.columnconfigure(1, weight=1)

    def add_item_row(self):
        desc_var = tk.StringVar()
        price_var = tk.StringVar()
        row = len(self.items)
        tk.Entry(self.items_frame, textvariable=desc_var).grid(row=row, column=0, sticky="ew")
        tk.Entry(self.items_frame, textvariable=price_var).grid(row=row, column=1, sticky="ew")
        self.items.append((desc_var, price_var))

    def save_invoice(self):
        customer = self.customer_var.get().strip()
        vehicle = self.vehicle_var.get().strip()
        if not customer or not vehicle:
            messagebox.showerror("Fehler", "Kunde und Fahrzeug angeben")
            return

        positions = []
        total = 0.0
        for desc_var, price_var in self.items:
            desc = desc_var.get().strip()
            try:
                price = float(price_var.get()) if price_var.get().strip() else 0.0
            except ValueError:
                messagebox.showerror("Fehler", f"Ungueltiger Preis '{price_var.get()}'")
                return
            if desc:
                positions.append({"text": desc, "preis": price})
                total += price

        if not positions:
            messagebox.showerror("Fehler", "Mindestens eine Position angeben")
            return

        invoice = {
            "kunde": customer,
            "fahrzeug": vehicle,
            "positionen": positions,
            "gesamt": total
        }

        try:
            with open("invoices.json", "r", encoding="utf8") as f:
                data = json.load(f)
        except FileNotFoundError:
            data = []

        invoice_nr = len(data) + 1
        invoice["rechnung_nr"] = f"R-{invoice_nr:03d}"
        data.append(invoice)
        with open("invoices.json", "w", encoding="utf8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

        messagebox.showinfo("Gespeichert", f"Rechnung {invoice['rechnung_nr']} gespeichert")
        self.master.destroy()


def main():
    root = tk.Tk()
    InvoiceApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
