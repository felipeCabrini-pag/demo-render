package com.example.demo.service;

import com.example.demo.model.Person;
import com.example.demo.repository.PersonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PersonService {
    
    private final PersonRepository personRepository;
    
    public List<Person> findAll() {
        return personRepository.findAll();
    }
    
    public Optional<Person> findById(Long id) {
        return personRepository.findById(id);
    }
    
    public Optional<Person> findByEmail(String email) {
        return personRepository.findByEmail(email);
    }
    
    public Person save(Person person) {
        return personRepository.save(person);
    }
    
    public void deleteById(Long id) {
        personRepository.deleteById(id);
    }
    
    public boolean existsByEmail(String email) {
        return personRepository.existsByEmail(email);
    }
}
