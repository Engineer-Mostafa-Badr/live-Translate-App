package com.livetranslate.app

import android.content.Context
import java.io.File

class OfflineTranslationPlugin(private val context: Context) {
    
    private var isInitialized = false
    private val translationsDir: File by lazy {
        File(context.filesDir, "translations").apply {
            if (!exists()) mkdirs()
        }
    }
    
    // Simple translation dictionaries (placeholder)
    private val dictionaries = mutableMapOf<String, Map<String, String>>()
    
    /**
     * Initialize offline translation
     */
    fun initTranslation(): Boolean {
        return try {
            // Load available dictionaries
            loadDictionaries()
            isInitialized = true
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
    
    /**
     * Load dictionaries from files
     */
    private fun loadDictionaries() {
        // Load sample dictionaries
        dictionaries["en-ar"] = mapOf(
            "hello" to "مرحبا",
            "goodbye" to "وداعا",
            "thank you" to "شكرا",
            "welcome" to "أهلا وسهلا",
            "yes" to "نعم",
            "no" to "لا",
            "please" to "من فضلك",
            "sorry" to "آسف"
        )
        
        dictionaries["ar-en"] = mapOf(
            "مرحبا" to "hello",
            "وداعا" to "goodbye",
            "شكرا" to "thank you",
            "أهلا وسهلا" to "welcome",
            "نعم" to "yes",
            "لا" to "no",
            "من فضلك" to "please",
            "آسف" to "sorry"
        )
    }
    
    /**
     * Translate text
     */
    fun translate(text: String, from: String, to: String): String? {
        if (!isInitialized) {
            return null
        }
        
        return try {
            val dictKey = "$from-$to"
            val dictionary = dictionaries[dictKey]
            
            if (dictionary != null) {
                // Simple word-by-word translation
                val words = text.lowercase().split(" ")
                val translated = words.map { word ->
                    dictionary[word] ?: word
                }.joinToString(" ")
                
                translated
            } else {
                // Return original text if no dictionary available
                text
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * Check if language pack is downloaded
     */
    fun isLanguageDownloaded(languageCode: String): Boolean {
        val langFile = File(translationsDir, "$languageCode.json")
        return langFile.exists()
    }
    
    /**
     * Dispose resources
     */
    fun dispose() {
        dictionaries.clear()
        isInitialized = false
    }
}
