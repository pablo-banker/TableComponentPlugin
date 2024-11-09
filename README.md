# TableComponent Plugin

The `TableComponent` is a powerful plugin for Godot that allows you to create interactive tables with support for customizable headers, pagination, scrolling, and dynamic loading. It is ideal for displaying data lists or creating user interfaces with organized columns, offering intuitive and flexible functionalities.

## Features

- **Customizable Header**: Define column headers with properties like width, font, and alignment.
- **Dynamic Rows**: Display a list of data with automatic updates and scrolling.
- **Custom Rows**: Create customizable rows for more flexibility in design and cell functionality.
- **Integrated Pagination**: Navigation between pages to handle large data sets.
- **Search**: Allows searching for specific values in the rows of the table.
- **Global and Local Loading States**: Visual control for loading states with global and local loading components.

## Table Structure

The `TableComponent` is divided into several sections that adapt automatically based on the received data.

### Header
The column headers can be defined for each table, with properties such as:
- `ID`: A unique name for reference in searching and updating data.
- `Title`: The name displayed in the column header.
- `Width`: The width of the column (optional).
- `Font and Font Size`: Customize the appearance of the header.

### Rows

`Rows` are the standard instances of the rows in the table, where each row represents a data set associated with the columns in the header. Rows are created dynamically from the provided data and can be updated as needed. Each row includes:
- **Position Index**: Displays the row number in the table.
- **Cell Values**: Each cell corresponds to a column in the header and displays the associated data.

### Custom Rows

`Custom Rows` offer greater control and flexibility for defining the appearance and functionality of specific rows. To create a custom row:

1. **Duplicate the Default Row Node**: Within the project, copy the default `TableRowComponent` node to preserve the structure and references.
2. **Assign a Custom Script**: Apply a new script to the duplicated row, using `extends TableRowComponent`. This allows you to override methods or add new behaviors for that specific row.
3. **Integration with the Table**: After configuring your custom row, it can be added to the table and will display the custom functionality you implemented.

This feature is useful for creating rows with special behaviors or displaying data in unconventional ways, while maintaining the same header structure and data system.

## Signals

The `TableComponent` has several signals that facilitate interaction with the table:

- `on_row_pressed(data: Dictionary)`: Emitted when a row is pressed, passing the row data as a dictionary.
- `on_list_rows(rows)`: Emitted when listing all visible rows in the table.
- `on_next_page`: Emitted when navigating to the next page.
- `on_previous_page`: Emitted when navigating to the previous page.

## Main API and Methods

### Table Configuration and Updates

- `set_header()`: Defines the table header based on the provided information.
- `set_rows()`: Populates the table rows with the given data.
- `set_pagination(items, total, page)`: Configures pagination based on items and total page count.

### Search and Filters

- `static_search(column_id, value)`: Searches for specific values in the displayed rows, showing only matching items.
- `iterate_refresh(new_data, row_inst, limit, page_index)`: Iteratively updates the table with new data, ensuring rows stay within the specified limits.
