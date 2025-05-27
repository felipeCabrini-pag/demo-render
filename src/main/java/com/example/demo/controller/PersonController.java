package com.example.demo.controller;

import com.example.demo.model.Person;
import com.example.demo.service.PersonService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
public class PersonController {
    
    private final PersonService personService;
    
    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("persons", personService.findAll());
        model.addAttribute("person", new Person());
        return "index";
    }
    
    @PostMapping("/person")
    public String addPerson(@Valid @ModelAttribute Person person, 
                           BindingResult bindingResult, 
                           Model model, 
                           RedirectAttributes redirectAttributes) {
        
        if (bindingResult.hasErrors()) {
            model.addAttribute("persons", personService.findAll());
            return "index";
        }
        
        if (personService.existsByEmail(person.getEmail())) {
            bindingResult.rejectValue("email", "email.exists", "Email already exists");
            model.addAttribute("persons", personService.findAll());
            return "index";
        }
        
        personService.save(person);
        redirectAttributes.addFlashAttribute("success", "Person added successfully!");
        return "redirect:/";
    }
    
    @GetMapping("/person/{id}/delete")
    public String deletePerson(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        personService.deleteById(id);
        redirectAttributes.addFlashAttribute("success", "Person deleted successfully!");
        return "redirect:/";
    }
}
