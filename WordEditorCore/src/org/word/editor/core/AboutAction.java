package org.word.editor.core;

import org.openide.awt.ActionID;
import org.openide.awt.ActionReference;
import org.openide.awt.ActionRegistration;
import javax.swing.*;
import java.awt.event.ActionEvent;

@ActionID(
        category = "Help",
        id = "org.word.editor.core.about"
)
@ActionRegistration(
        displayName = "About Word Processor"
)
@ActionReference(path = "Menu/Help", position = 100)
public final class AboutAction extends AbstractAction {

    @Override
    public void actionPerformed(ActionEvent e) {
        AboutDialog dialog = new AboutDialog(null);
        dialog.setVisible(true);
    }
}
