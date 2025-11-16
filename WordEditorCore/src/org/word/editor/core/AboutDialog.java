package org.word.editor.core;

import org.word.editor.core.util.AppVersion;
import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;

public class AboutDialog extends JDialog {

    public AboutDialog(Frame parent) {
        super(parent, "About Word Processor", true);
        initComponents();
    }

    private void initComponents() {
        setLayout(new BorderLayout(10, 10));
        setResizable(false);

        JPanel contentPanel = new JPanel(new BorderLayout(20, 20));
        contentPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        // Title
        JLabel titleLabel = new JLabel("Word Processor", JLabel.CENTER);
        titleLabel.setFont(new Font("SansSerif", Font.BOLD, 18));

        // Version
        String version = AppVersion.getVersion();
        JLabel versionLabel = new JLabel();
        versionLabel.setText("Word Processor Version: " + version);
        versionLabel.setFont(new Font("SansSerif", Font.PLAIN, 12));

        // Copyright
        JLabel copyrightLabel = new JLabel("© Example copyright", JLabel.CENTER);
        copyrightLabel.setFont(new Font("SansSerif", Font.PLAIN, 10));
        copyrightLabel.setForeground(Color.GRAY);

        // Close button
        JButton closeButton = new JButton("Close");
        closeButton.addActionListener((ActionEvent e) -> {
            dispose();
        });

        JPanel buttonPanel = new JPanel();
        buttonPanel.add(closeButton);

        contentPanel.add(titleLabel, BorderLayout.NORTH);
        contentPanel.add(versionLabel, BorderLayout.CENTER);
        contentPanel.add(copyrightLabel, BorderLayout.SOUTH);

        add(contentPanel, BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);

        pack();
        setLocationRelativeTo(getParent());
    }
}
