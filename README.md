# Crab_SwapableTableView
SwapebleTableView like mail app in IOS

SwapeableTableView created like the mail app in IOS.
Based on references :
http://www.teehanlax.com/blog/reproducing-the-ios-7-mail-apps-interface/
and Chinese materials:http://blog.jobbole.com/67272/

But finally i dont think to pan the cell to delete is a good experience, even it seems to be awesome for me.
I deleted many unread mails accidentally!...

In my solution , the editing area is customizable for the users:

-(UIView*)editingAreaForCell:(UITableViewCell *)cell

you can impletement it in your controller to customize your own view.

All views is xib-able in storyboard,so all the visual views in xib files can be edited.
And the source behind is just to fix the constraints while panning.

