/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package org.word.editor.uppercase;

import org.openide.util.lookup.ServiceProvider;
import org.word.editor.api.WordFilter;

/**
 *
 * @author ianik
 */
// Add the class as a service provider
@ServiceProvider(service = WordFilter.class)
public class UppercaseFilter implements WordFilter {

    @Override
    public String process(String s) {
        return s.toUpperCase();
    }
}
