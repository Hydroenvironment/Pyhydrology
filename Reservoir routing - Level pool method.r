################################################################################
# RESERVOIR FLOW ROUTING USING LEVEL POOL METHOD                               #
################################################################################
#Author: Julio Montenegro Gambini,M.Sc.,

#Importing libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.io as pio

# Data from the problem
time = np.array([0, 2, 4, 6, 8, 10, 12, 14, 16, 18])  # hours
inflow = np.array([60, 100, 232, 300, 520, 1310, 1930, 1460, 930, 650])  # m^3/s
storage = np.array([75, 81, 87.5, 100, 110.2]) * 1e6  # m^3
outflow = np.array([57, 227, 519, 1330, 2270])  # m^3/s

# Initial storage
initial_storage = 75e6  # m^3

# Data interpolation function to find storage for given inflow
def interpolate_storage(flow):
    return np.interp(flow, outflow, storage)

# Data interpolation function to find outflow for given storage
def interpolate_outflow(store):
    return np.interp(store, storage, outflow)

# Initialize lists to store the results
storages = [initial_storage]
outflows = [interpolate_outflow(initial_storage)]

# Routing calculation using level pool method
for i in range(1, len(time)):
    dt = (time[i] - time[i-1]) * 3600  # time step in seconds
    inflow_avg = (inflow[i] + inflow[i-1]) / 2
    storage_prev = storages[-1]
    outflow_prev = outflows[-1]

    # Solve for next storage using continuity equation
    storage_next = storage_prev + dt * (inflow_avg - outflow_prev)
    storages.append(storage_next)

    # Get the corresponding outflow for the new storage
    outflow_next = interpolate_outflow(storage_next)
    outflows.append(outflow_next)

# Convert lists to arrays
storages = np.array(storages)
outflows = np.array(outflows)

# Create a DataFrame for easier manipulation
df = pd.DataFrame({
    'Time (h)': time,
    'Inflow (m^3/s)': inflow,
    'Outflow (m^3/s)': outflows,
    'Storage (m^3)': storages
})

# Plotting with Matplotlib
plt.figure(figsize=(12, 8))

# Plot inflow
plt.plot(df['Time (h)'], df['Inflow (m^3/s)'], label='Inflow', marker='o')
# Plot outflow
plt.plot(df['Time (h)'], df['Outflow (m^3/s)'], label='Outflow', marker='x')
# Plot storage
plt.plot(df['Time (h)'], df['Storage (m^3)']/1e6, label='Storage (10^6 m^3)', marker='s')

plt.xlabel('Time (hours)')
plt.ylabel('Flow (m^3/s) / Storage (10^6 m^3)')
plt.title('Hydrograph Routing using Level Pool Method')
plt.legend()
plt.grid(True)
plt.show()

# Interactive plot with Plotly
fig = px.line(df, x='Time (h)', y=['Inflow (m^3/s)', 'Outflow (m^3/s)'],
              title='Hydrograph Routing using Level Pool Method',
              labels={'value': 'Flow (m^3/s) / Storage (m^3)', 'variable': 'Parameter'},
              markers=True)
pio.renderers.default='browser'
# Customize interactive plot
fig.update_traces(mode='markers+lines')
fig.update_layout(yaxis_title='Flow (m^3/s) / Storage (m^3)')

# Show interactive plot
fig.show()
