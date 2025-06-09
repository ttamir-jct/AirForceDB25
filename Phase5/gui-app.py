import tkinter as tk
from tkinter import ttk, messagebox
import psycopg2

# Database connection
def get_db_connection():
    return psycopg2.connect(
       host="localhost",
        database="AirForceDB",
        user="ttamir",
        password="4yT5rZ2a",
        port="5432" 
    )

# Main Application
class AviationApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Aviation Management System")
        self.root.configure(bg="#f0f0f0")  # Light gray background
        self.root.geometry("900x800")  # Adjusted for side-by-side layout
        self.show_main_screen()

    def show_main_screen(self):
        for widget in self.root.winfo_children():
            widget.destroy()
        tk.Label(self.root, text="Aviation Management System", font=("Arial", 16, "bold"), bg="#f0f0f0").pack(pady=20)
        tk.Button(self.root, text="Manage Pilots", command=self.show_pilot_management, bg="#4CAF50", fg="white", padx=10, pady=5).pack(pady=10)
        tk.Button(self.root, text="Manage Operators", command=self.show_operator_management, bg="#2196F3", fg="white", padx=10, pady=5).pack(pady=10)
        tk.Button(self.root, text="Manage Hubs", command=self.show_hub_management, bg="#FF9800", fg="white", padx=10, pady=5).pack(pady=10)
        tk.Button(self.root, text="Operations Dashboard", command=self.show_operations_dashboard, bg="#9C27B0", fg="white", padx=10, pady=5).pack(pady=10)

    def show_pilot_management(self):
        for widget in self.root.winfo_children():
            widget.destroy()
        tk.Label(self.root, text="Pilot Management", font=("Arial", 14), bg="#f0f0f0").pack(pady=15)

        # Create a canvas with scrollbar
        canvas = tk.Canvas(self.root)
        scrollbar = ttk.Scrollbar(self.root, orient="vertical", command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Center the content
        main_frame = ttk.Frame(scrollable_frame)
        main_frame.pack(expand=True)

        # Add Section
        tk.Label(main_frame, text="Add New Pilot", font=("Arial", 12, "bold")).pack(pady=10)
        add_frame = ttk.Frame(main_frame)
        add_frame.pack(pady=10, padx=10)
        self.pilot_id_entry = tk.Entry(add_frame)
        self.pilot_id_entry.grid(row=0, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Pilot ID").grid(row=0, column=0, pady=5, padx=5)
        self.fullname_entry = tk.Entry(add_frame)
        self.fullname_entry.grid(row=1, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Full Name").grid(row=1, column=0, pady=5, padx=5)
        self.next_training_entry = tk.Entry(add_frame)
        self.next_training_entry.grid(row=2, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Next Training Date").grid(row=2, column=0, pady=5, padx=5)
        self.rank_entry = tk.Entry(add_frame)
        self.rank_entry.grid(row=3, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Rank").grid(row=3, column=0, pady=5, padx=5)
        self.aircraft_id_entry = tk.Entry(add_frame)
        self.aircraft_id_entry.grid(row=4, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Aircraft ID").grid(row=4, column=0, pady=5, padx=5)
        self.license_num_entry = tk.Entry(add_frame)
        self.license_num_entry.grid(row=5, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="License Number").grid(row=5, column=0, pady=5, padx=5)
        self.experience_entry = tk.Entry(add_frame)
        self.experience_entry.grid(row=6, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Experience").grid(row=6, column=0, pady=5, padx=5)
        self.operator_id_entry = tk.Entry(add_frame)
        self.operator_id_entry.grid(row=7, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Operator ID").grid(row=7, column=0, pady=5, padx=5)
        tk.Button(add_frame, text="Insert", command=self.insert_pilot, bg="#4CAF50", fg="white").grid(row=8, column=0, columnspan=2, pady=10, padx=5)

        # View/Edit Section
        tk.Label(main_frame, text="Existing Pilots", font=("Arial", 12, "bold")).pack(pady=10)
        self.pilot_tree = ttk.Treeview(main_frame, columns=("ID", "Full Name", "Next Training", "Rank", "Aircraft ID", "License", "Experience", "Operator ID"), show="headings")
        for col in self.pilot_tree["columns"]:
            self.pilot_tree.heading(col, text=col.replace("_", " ").title())
        self.pilot_tree.pack(pady=10, padx=10, fill="both", expand=True)
        self.load_pilot_data()
        tk.Button(main_frame, text="Update", command=self.update_pilot, bg="#2196F3", fg="white").pack(pady=10)
        tk.Button(main_frame, text="Delete", command=self.delete_pilot, bg="#F44336", fg="white").pack(pady=10)
        tk.Button(main_frame, text="Back", command=self.show_main_screen, bg="#9C27B0", fg="white").pack(pady=15)

    def load_pilot_data(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("SELECT pilotid, fullname, nexttrainingdate, rank, aircraftid, license_num, experience, operator_id FROM pilot ORDER BY pilotid")
            for row in cur.fetchall():
                self.pilot_tree.insert("", tk.END, values=row)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def insert_pilot(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("INSERT INTO pilot (pilotid, fullname, nexttrainingdate, rank, aircraftid, license_num, experience, operator_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                        (int(self.pilot_id_entry.get()), self.fullname_entry.get(), self.next_training_entry.get(),
                         self.rank_entry.get(), int(self.aircraft_id_entry.get()) if self.aircraft_id_entry.get() else None,
                         self.license_num_entry.get(), int(self.experience_entry.get()), int(self.operator_id_entry.get()) if self.operator_id_entry.get() else None))
            conn.commit()
            messagebox.showinfo("Success", "Pilot inserted")
            self.load_pilot_data()
            for entry in [self.pilot_id_entry, self.fullname_entry, self.next_training_entry, self.rank_entry,
                          self.aircraft_id_entry, self.license_num_entry, self.experience_entry, self.operator_id_entry]:
                entry.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def update_pilot(self):
        selected_item = self.pilot_tree.selection()
        if not selected_item:
            messagebox.showwarning("Warning", "Please select a pilot to update")
            return
        values = self.pilot_tree.item(selected_item)["values"]
        self.edit_window = tk.Toplevel(self.root)
        self.edit_window.title("Edit Pilot")
        tk.Label(self.edit_window, text="Pilot ID").grid(row=0, column=0, pady=5, padx=5)
        tk.Entry(self.edit_window, textvariable=tk.StringVar(value=values[0]), state="disabled").grid(row=0, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Full Name").grid(row=1, column=0, pady=5, padx=5)
        fullname_entry = tk.Entry(self.edit_window)
        fullname_entry.insert(0, values[1])
        fullname_entry.grid(row=1, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Next Training Date").grid(row=2, column=0, pady=5, padx=5)
        training_entry = tk.Entry(self.edit_window)
        training_entry.insert(0, values[2])
        training_entry.grid(row=2, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Rank").grid(row=3, column=0, pady=5, padx=5)
        rank_entry = tk.Entry(self.edit_window)
        rank_entry.insert(0, values[3])
        rank_entry.grid(row=3, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Aircraft ID").grid(row=4, column=0, pady=5, padx=5)
        aircraft_entry = tk.Entry(self.edit_window)
        aircraft_entry.insert(0, values[4] if values[4] else "")
        aircraft_entry.grid(row=4, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="License Number").grid(row=5, column=0, pady=5, padx=5)
        license_entry = tk.Entry(self.edit_window)
        license_entry.insert(0, values[5])
        license_entry.grid(row=5, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Experience").grid(row=6, column=0, pady=5, padx=5)
        experience_entry = tk.Entry(self.edit_window)
        experience_entry.insert(0, values[6])
        experience_entry.grid(row=6, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Operator ID").grid(row=7, column=0, pady=5, padx=5)
        operator_entry = tk.Entry(self.edit_window)
        operator_entry.insert(0, values[7] if values[7] else "")
        operator_entry.grid(row=7, column=1, pady=5, padx=5)
        tk.Button(self.edit_window, text="Save", command=lambda: self.save_pilot_update(selected_item, fullname_entry.get(), training_entry.get(), rank_entry.get(), aircraft_entry.get(), license_entry.get(), experience_entry.get(), operator_entry.get()), bg="#2196F3", fg="white").grid(row=8, column=0, columnspan=2, pady=10, padx=5)

    def save_pilot_update(self, item, fullname, next_training, rank, aircraft_id, license_num, experience, operator_id):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            pilot_id = int(self.pilot_tree.item(item)["values"][0])
            cur.execute("UPDATE pilot SET fullname = %s, nexttrainingdate = %s, rank = %s, aircraftid = %s, license_num = %s, experience = %s, operator_id = %s WHERE pilotid = %s",
                        (fullname, next_training, rank, int(aircraft_id) if aircraft_id else None, license_num, int(experience), int(operator_id) if operator_id else None, pilot_id))
            conn.commit()
            messagebox.showinfo("Success", "Pilot updated")
            self.edit_window.destroy()
            self.load_pilot_data()
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def delete_pilot(self):
        selected_item = self.pilot_tree.selection()
        if not selected_item:
            messagebox.showwarning("Warning", "Please select a pilot to delete")
            return
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            pilot_id = int(self.pilot_tree.item(selected_item)["values"][0])
            cur.execute("DELETE FROM pilot WHERE pilotid = %s", (pilot_id,))
            conn.commit()
            messagebox.showinfo("Success", f"Pilot {pilot_id} deleted")
            self.load_pilot_data()
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def show_operator_management(self):
        for widget in self.root.winfo_children():
            widget.destroy()
        tk.Label(self.root, text="Operator Management", font=("Arial", 14), bg="#f0f0f0").pack(pady=15)

        # Create a canvas with scrollbar
        canvas = tk.Canvas(self.root)
        scrollbar = ttk.Scrollbar(self.root, orient="vertical", command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Center the content
        main_frame = ttk.Frame(scrollable_frame)
        main_frame.pack(expand=True)

        # Add Section
        tk.Label(main_frame, text="Add New Operator", font=("Arial", 12, "bold")).pack(pady=10)
        add_frame = ttk.Frame(main_frame)
        add_frame.pack(pady=10, padx=10)
        self.operator_id_entry = tk.Entry(add_frame)
        self.operator_id_entry.grid(row=0, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Operator ID").grid(row=0, column=0, pady=5, padx=5)
        self.operator_name_entry = tk.Entry(add_frame)
        self.operator_name_entry.grid(row=1, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Name").grid(row=1, column=0, pady=5, padx=5)
        self.fleet_size_entry = tk.Entry(add_frame)
        self.fleet_size_entry.grid(row=2, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Fleet Size").grid(row=2, column=0, pady=5, padx=5)
        self.operator_type_entry = tk.Entry(add_frame)
        self.operator_type_entry.grid(row=3, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Type").grid(row=3, column=0, pady=5, padx=5)
        self.hub_id_entry = tk.Entry(add_frame)
        self.hub_id_entry.grid(row=4, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Hub ID").grid(row=4, column=0, pady=5, padx=5)
        tk.Button(add_frame, text="Insert", command=self.insert_operator, bg="#4CAF50", fg="white").grid(row=5, column=0, columnspan=2, pady=10, padx=5)

        # View/Edit Section
        tk.Label(main_frame, text="Existing Operators", font=("Arial", 12, "bold")).pack(pady=10)
        self.operator_tree = ttk.Treeview(main_frame, columns=("ID", "Name", "Fleet Size", "Type", "Hub ID"), show="headings")
        for col in self.operator_tree["columns"]:
            self.operator_tree.heading(col, text=col.replace("_", " ").title())
        self.operator_tree.pack(pady=10, padx=10, fill="both", expand=True)
        self.load_operator_data()
        tk.Button(main_frame, text="Update", command=self.update_operator, bg="#2196F3", fg="white").pack(pady=10)
        tk.Button(main_frame, text="Delete", command=self.delete_operator, bg="#F44336", fg="white").pack(pady=10)
        tk.Button(main_frame, text="Back", command=self.show_main_screen, bg="#9C27B0", fg="white").pack(pady=15)

    def load_operator_data(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("SELECT operator_id, name, fleet_size, type, hub_id FROM operator ORDER BY operator_id")
            for row in cur.fetchall():
                self.operator_tree.insert("", tk.END, values=row)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def insert_operator(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("INSERT INTO operator (operator_id, name, fleet_size, type, hub_id) VALUES (%s, %s, %s, %s, %s)",
                        (int(self.operator_id_entry.get()), self.operator_name_entry.get(), int(self.fleet_size_entry.get()),
                         self.operator_type_entry.get(), int(self.hub_id_entry.get())))
            conn.commit()
            messagebox.showinfo("Success", "Operator inserted")
            self.load_operator_data()
            for entry in [self.operator_id_entry, self.operator_name_entry, self.fleet_size_entry, self.operator_type_entry, self.hub_id_entry]:
                entry.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def update_operator(self):
        selected_item = self.operator_tree.selection()
        if not selected_item:
            messagebox.showwarning("Warning", "Please select an operator to update")
            return
        values = self.operator_tree.item(selected_item)["values"]
        self.edit_window = tk.Toplevel(self.root)
        self.edit_window.title("Edit Operator")
        tk.Label(self.edit_window, text="Operator ID").grid(row=0, column=0, pady=5, padx=5)
        tk.Entry(self.edit_window, textvariable=tk.StringVar(value=values[0]), state="disabled").grid(row=0, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Name").grid(row=1, column=0, pady=5, padx=5)
        name_entry = tk.Entry(self.edit_window)
        name_entry.insert(0, values[1])
        name_entry.grid(row=1, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Fleet Size").grid(row=2, column=0, pady=5, padx=5)
        fleet_entry = tk.Entry(self.edit_window)
        fleet_entry.insert(0, values[2])
        fleet_entry.grid(row=2, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Type").grid(row=3, column=0, pady=5, padx=5)
        type_entry = tk.Entry(self.edit_window)
        type_entry.insert(0, values[3])
        type_entry.grid(row=3, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Hub ID").grid(row=4, column=0, pady=5, padx=5)
        hub_entry = tk.Entry(self.edit_window)
        hub_entry.insert(0, values[4])
        hub_entry.grid(row=4, column=1, pady=5, padx=5)
        tk.Button(self.edit_window, text="Save", command=lambda: self.save_operator_update(selected_item, name_entry.get(), fleet_entry.get(), type_entry.get(), hub_entry.get()), bg="#2196F3", fg="white").grid(row=5, column=0, columnspan=2, pady=10, padx=5)

    def save_operator_update(self, item, name, fleet_size, type_, hub_id):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            operator_id = int(self.operator_tree.item(item)["values"][0])
            cur.execute("UPDATE operator SET name = %s, fleet_size = %s, type = %s, hub_id = %s WHERE operator_id = %s",
                        (name, int(fleet_size), type_, int(hub_id), operator_id))
            conn.commit()
            messagebox.showinfo("Success", "Operator updated")
            self.edit_window.destroy()
            self.load_operator_data()
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def delete_operator(self):
        selected_item = self.operator_tree.selection()
        if not selected_item:
            messagebox.showwarning("Warning", "Please select an operator to delete")
            return
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            operator_id = int(self.operator_tree.item(selected_item)["values"][0])
            cur.execute("DELETE FROM operator WHERE operator_id = %s", (operator_id,))
            conn.commit()
            messagebox.showinfo("Success", f"Operator {operator_id} deleted")
            self.load_operator_data()
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def show_hub_management(self):
        for widget in self.root.winfo_children():
            widget.destroy()
        tk.Label(self.root, text="Hub Management", font=("Arial", 14), bg="#f0f0f0").pack(pady=15)

        # Create a canvas with scrollbar
        canvas = tk.Canvas(self.root)
        scrollbar = ttk.Scrollbar(self.root, orient="vertical", command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Center the content
        main_frame = ttk.Frame(scrollable_frame)
        main_frame.pack(expand=True)

        # Add Section
        tk.Label(main_frame, text="Add New Hub", font=("Arial", 12, "bold")).pack(pady=10)
        add_frame = ttk.Frame(main_frame)
        add_frame.pack(pady=10, padx=10)
        self.hub_id_entry = tk.Entry(add_frame)
        self.hub_id_entry.grid(row=0, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Hub ID").grid(row=0, column=0, pady=5, padx=5)
        self.hub_name_entry = tk.Entry(add_frame)
        self.hub_name_entry.grid(row=1, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Name").grid(row=1, column=0, pady=5, padx=5)
        self.location_entry = tk.Entry(add_frame)
        self.location_entry.grid(row=2, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Location").grid(row=2, column=0, pady=5, padx=5)
        self.iata_code_entry = tk.Entry(add_frame)
        self.iata_code_entry.grid(row=3, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="IATA Code").grid(row=3, column=0, pady=5, padx=5)
        self.capacity_entry = tk.Entry(add_frame)
        self.capacity_entry.grid(row=4, column=1, pady=5, padx=5)
        tk.Label(add_frame, text="Capacity").grid(row=4, column=0, pady=5, padx=5)
        tk.Button(add_frame, text="Insert", command=self.insert_hub, bg="#4CAF50", fg="white").grid(row=5, column=0, columnspan=2, pady=10, padx=5)

        # View/Edit Section
        tk.Label(main_frame, text="Existing Hubs", font=("Arial", 12, "bold")).pack(pady=10)
        self.hub_tree = ttk.Treeview(main_frame, columns=("ID", "Name", "Location", "IATA Code", "Capacity"), show="headings")
        for col in self.hub_tree["columns"]:
            self.hub_tree.heading(col, text=col.replace("_", " ").title())
        self.hub_tree.pack(pady=10, padx=10, fill="both", expand=True)
        self.load_hub_data()
        tk.Button(main_frame, text="Update", command=self.update_hub, bg="#2196F3", fg="white").pack(pady=10)
        tk.Button(main_frame, text="Delete", command=self.delete_hub, bg="#F44336", fg="white").pack(pady=10)
        tk.Button(main_frame, text="Back", command=self.show_main_screen, bg="#9C27B0", fg="white").pack(pady=15)

    def load_hub_data(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("SELECT hub_id, name, location, iata_code, capacity FROM hub ORDER BY hub_id")
            for row in cur.fetchall():
                self.hub_tree.insert("", tk.END, values=row)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def insert_hub(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("INSERT INTO hub (hub_id, name, location, iata_code, capacity) VALUES (%s, %s, %s, %s, %s)",
                        (int(self.hub_id_entry.get()), self.hub_name_entry.get(), self.location_entry.get(),
                         self.iata_code_entry.get(), int(self.capacity_entry.get())))
            conn.commit()
            messagebox.showinfo("Success", "Hub inserted")
            self.load_hub_data()
            for entry in [self.hub_id_entry, self.hub_name_entry, self.location_entry, self.iata_code_entry, self.capacity_entry]:
                entry.delete(0, tk.END)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def update_hub(self):
        selected_item = self.hub_tree.selection()
        if not selected_item:
            messagebox.showwarning("Warning", "Please select a hub to update")
            return
        values = self.hub_tree.item(selected_item)["values"]
        self.edit_window = tk.Toplevel(self.root)
        self.edit_window.title("Edit Hub")
        tk.Label(self.edit_window, text="Hub ID").grid(row=0, column=0, pady=5, padx=5)
        tk.Entry(self.edit_window, textvariable=tk.StringVar(value=values[0]), state="disabled").grid(row=0, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Name").grid(row=1, column=0, pady=5, padx=5)
        name_entry = tk.Entry(self.edit_window)
        name_entry.insert(0, values[1])
        name_entry.grid(row=1, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Location").grid(row=2, column=0, pady=5, padx=5)
        location_entry = tk.Entry(self.edit_window)
        location_entry.insert(0, values[2])
        location_entry.grid(row=2, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="IATA Code").grid(row=3, column=0, pady=5, padx=5)
        iata_entry = tk.Entry(self.edit_window)
        iata_entry.insert(0, values[3])
        iata_entry.grid(row=3, column=1, pady=5, padx=5)
        tk.Label(self.edit_window, text="Capacity").grid(row=4, column=0, pady=5, padx=5)
        capacity_entry = tk.Entry(self.edit_window)
        capacity_entry.insert(0, values[4])
        capacity_entry.grid(row=4, column=1, pady=5, padx=5)
        tk.Button(self.edit_window, text="Save", command=lambda: self.save_hub_update(selected_item, name_entry.get(), location_entry.get(), iata_entry.get(), capacity_entry.get()), bg="#2196F3", fg="white").grid(row=5, column=0, columnspan=2, pady=10, padx=5)

    def save_hub_update(self, item, name, location, iata_code, capacity):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            hub_id = int(self.hub_tree.item(item)["values"][0])
            cur.execute("UPDATE hub SET name = %s, location = %s, iata_code = %s, capacity = %s WHERE hub_id = %s",
                        (name, location, iata_code, int(capacity), hub_id))
            conn.commit()
            messagebox.showinfo("Success", "Hub updated")
            self.edit_window.destroy()
            self.load_hub_data()
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def delete_hub(self):
        selected_item = self.hub_tree.selection()
        if not selected_item:
            messagebox.showwarning("Warning", "Please select a hub to delete")
            return
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            hub_id = int(self.hub_tree.item(selected_item)["values"][0])
            cur.execute("DELETE FROM hub WHERE hub_id = %s", (hub_id,))
            conn.commit()
            messagebox.showinfo("Success", f"Hub {hub_id} deleted")
            self.load_hub_data()
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def show_operations_dashboard(self):
        for widget in self.root.winfo_children():
            widget.destroy()
        tk.Label(self.root, text="Operations Dashboard", font=("Arial", 14), bg="#f0f0f0").pack(pady=15)

        # Fuel Stock Operations Section
        tk.Label(self.root, text="Fuel Stock Operations", font=("Arial", 12, "bold")).pack(pady=10)
        fuel_frame = ttk.Frame(self.root)
        fuel_frame.pack(pady=10, padx=10)
        tk.Label(fuel_frame, text="Stock ID").grid(row=0, column=0, pady=5, padx=5)
        stock_id_entry = tk.Entry(fuel_frame)
        stock_id_entry.grid(row=0, column=1, pady=5, padx=5)
        tk.Button(fuel_frame, text="Restock Fuel", command=lambda: self.execute_procedure1(stock_id_entry.get()), bg="#FF9800", fg="white").grid(row=1, column=0, pady=5, padx=5)
        tk.Button(fuel_frame, text="Next Restock Date", command=lambda: self.execute_function1(stock_id_entry.get()), bg="#9C27B0", fg="white").grid(row=1, column=1, pady=5, padx=5)
        self.fuel_result_text = tk.Text(self.root, height=5, width=50, bg="white")
        self.fuel_result_text.pack(pady=10)

        # Selection Queries Section
        tk.Label(self.root, text="Selection Queries", font=("Arial", 12, "bold")).pack(pady=10)
        query_frame = ttk.Frame(self.root)
        query_frame.pack(pady=10, padx=10)
        tk.Button(query_frame, text="Longest range planes per squadron", command=lambda: self.execute_query1(), bg="#4CAF50", fg="white").grid(row=1, column=0, pady=5, padx=5)
        tk.Button(query_frame, text="Pilots with overdue training", command=lambda: self.execute_query2(), bg="#2196F3", fg="white").grid(row=1, column=1, pady=5, padx=5)
        self.query_tree = ttk.Treeview(self.root, columns=("Result",), show="headings")
        self.query_tree.heading("Result", text="Result")
        self.query_tree.pack(pady=10, padx=10, fill="both", expand=True)
        tk.Button(self.root, text="Back", command=self.show_main_screen, bg="#9C27B0", fg="white").pack(pady=15)

    def execute_procedure1(self, stock_id):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("CALL RestockFuelIfLow(%s)", (int(stock_id),))
            conn.commit()
            self.fuel_result_text.delete(1.0, tk.END)
            self.fuel_result_text.insert(tk.END, f"Restock executed for StockId {stock_id}")
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def execute_function1(self, stock_id):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("SELECT CalculateNextRestockDate(%s) AS next_date", (int(stock_id),))
            result = cur.fetchone()
            self.fuel_result_text.delete(1.0, tk.END)
            self.fuel_result_text.insert(tk.END, f"Next Restock Date: {result[0]}")
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def execute_query1(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('''SELECT 
    s.SquadronName, 
    p.AircraftId, 
    a.ModelName, 
    p.MaxRange, 
    pi.FullName AS PilotName
FROM Plane p
JOIN Aircraft a ON p.AircraftId = a.AircraftId
JOIN Squadron s ON a.SquadronId = s.SquadronId
LEFT JOIN Pilot pi ON a.AircraftId = pi.AircraftId
WHERE (p.AircraftId, p.MaxRange) IN (
    SELECT p2.AircraftId, p2.MaxRange
    FROM Plane p2
    JOIN Aircraft a2 ON p2.AircraftId = a2.AircraftId
    WHERE a2.SquadronId = s.SquadronId
    ORDER BY p2.MaxRange DESC
    LIMIT 1
)
ORDER BY p.MaxRange DESC;''')
            results = cur.fetchall()
            for item in self.query_tree.get_children():
                self.query_tree.delete(item)
            self.query_tree["columns"] = [desc[0] for desc in cur.description]
            for col in self.query_tree["columns"]:
                self.query_tree.heading(col, text=col)
            for row in results:
                self.query_tree.insert("", tk.END, values=row)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

    def execute_query2(self):
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('''SELECT 
    p.PilotId, 
    p.FullName, 
    p.NextTrainingDate, 
    EXTRACT(DAY FROM AGE(CURRENT_DATE, p.NextTrainingDate)) AS DaysOverdue, 
    a.ModelName AS AssignedAircraft
FROM Pilot p
LEFT JOIN Aircraft a ON p.AircraftId = a.AircraftId
WHERE p.NextTrainingDate < CURRENT_DATE
ORDER BY DaysOverdue DESC;''')
            results = cur.fetchall()
            for item in self.query_tree.get_children():
                self.query_tree.delete(item)
            self.query_tree["columns"] = [desc[0] for desc in cur.description]
            for col in self.query_tree["columns"]:
                self.query_tree.heading(col, text=col)
            for row in results:
                self.query_tree.insert("", tk.END, values=row)
        except Exception as e:
            messagebox.showerror("Error", str(e))
        finally:
            conn.close()

# Run the application
if __name__ == "__main__":
    root = tk.Tk()
    app = AviationApp(root)
    root.mainloop()