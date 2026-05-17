
-- paste it in items.lua (ox_inventory)

	['receipt'] = {
    label = 'DMV Receipt',
    weight = 1,
    stack = true,
    close = true,
    description = 'Official DMV test receipt',
    client = {
        image = 'receipt.png',
        usetime = 2500,
        export = 'nexus_dmv.useReceipt'
		}
	},