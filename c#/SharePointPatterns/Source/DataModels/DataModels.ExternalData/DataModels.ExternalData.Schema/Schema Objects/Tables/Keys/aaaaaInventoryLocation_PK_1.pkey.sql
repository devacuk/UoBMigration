﻿ALTER TABLE [dbo].[InventoryLocations]
    ADD CONSTRAINT [aaaaaInventoryLocation_PK] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF) ON [PRIMARY];

