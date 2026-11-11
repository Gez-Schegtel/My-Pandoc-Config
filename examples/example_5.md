---
title: "Aclaraciones del Trabajo Práctico Integrador"
subtitle: "Parte 1"
author: Pollo, Denise, Juani, Chipancho, Lauti y Agustincincho
date: \today
documentclass: scrartcl
classoption: numbers=enddot
toc: true
toc-depth: 4
numbersections: true

---

\newpage

Este Trabajo Práctico (TP Nº1) aplica de punta a punta el **procedimiento de alineamiento estratégico de Andreu, Ricart y Valor (Fases I a IV)** sobre el caso real de la **Dirección de Vialidad Provincial del Chaco (DVP)**, integrando en el camino las herramientas de **Edwards, Ward y Bytheway** (FODA/entornos, cartera de aplicaciones y estrategias genéricas) y las de **Robson** (categorías de inversión y matriz de beneficios de Silk).

A continuación tenés una guía de estudio estructurada fase por fase para entender **qué se hizo, con qué teoría se justifica y cómo defender cada decisión en un examen o coloquio**:

---

# Fase I: Presentación y Compromiso del Equipo

**Objetivo teórico (Andreu, Ricart y Valor):** Que la planificación de $SI/TI$ sea asumida como un proyecto estratégico de toda la organización (liderado por la alta dirección) y no como un problema técnico aislado del área de informática.

* **Definición del negocio y rumbo estratégico:** Se establecen la misión operativa de la DVP (construir, conservar y administrar la red vial provincial) y sus **4 objetivos institucionales**, cuyo eje es optimizar el uso del Fondo Provincial de Vialidad y garantizar la conectividad regional en coordinación con municipios y organismos nacionales.


* **Relevamiento de la estructura orgánica:** Se identifican la máxima conducción (**Administrador General, Ing. Omar Canela**, y Subadministrador General), la conducción técnica (**Ingeniero Jefe**) y las **10 Direcciones** operativas y de soporte, destacando un dato estructural clave: el **Departamento de Informática depende directamente del Administrador General** (actuando como *staff* de la máxima autoridad, lo que facilita la alineación sin sesgos departamentales).


* **Conformación de los tres grupos de trabajo (Fig. 5.7 de Andreu):**

1. **Comité de $TI/SI$ (Nivel estratégico):** Integrado por el Directorio de Vialidad, el Ingeniero Jefe, los Directores de las áreas funcionales y la dirección de Informática. Su rol es fijar prioridades estratégicas, comprometer recursos y aprobar el Plan definitivo.


2. **Grupo Base (Nivel táctico y staff metodológico):** Integrado por el Directorio de Vialidad, el responsable de Informática, consultores externos (**ECOM CHACO**) y los jefes técnicos (Jefe de Sistemas y Jefe de Hardware y Comunicaciones). Asegura la consistencia metodológica, supervisa el día a día y facilita la negociación entre usuarios.


3. **Equipo de Trabajo (Nivel operativo):** Liderado en la práctica diaria por el **Director Operativo del Proyecto (DOP)** —rol asignado al Jefe de Sistemas—, acompañado por el Jefe de Hardware y Comunicaciones y los representantes clave (*Key Users*) de cada Dirección de negocio.





---

# Fase II: Descripción de la Situación Actual (*"¿Dónde estamos?"*)

**Objetivo teórico:** Diagnosticar la empresa desde dos dimensiones —**el negocio** (funciones y procesos) y **los sistemas actuales**—, realizando una doble crítica: de utilidad para el negocio y técnica.

## Análisis de los 4 Entornos mediante Matriz FODA (Edwards, cap. 4)

* **Fortalezas (Interno):** No se parte de cero; existen 11 sistemas operativos con bases de datos activas, hay compromiso explícito de la alta dirección (Ing. Canela, Kutnich, Viola, Derka), buena cultura de adopción digital (éxito previo al eliminar el papel en *Viaticar* y *Calificaciones*) y alcance provincial a través de *GesTaller*.


* **Debilidades (Interno):**

* **Sistemas "Silos":** *TallerDLM*, *StockDVP* y *OrdenesDVP* funcionan como islas desconectadas que obligan a cruces manuales.


* **Nula capacidad analítica (BI):** Los sistemas son meramente transaccionales (registran datos pero no generan reportes, alertas ni *dashboards* para decidir).


* **Procesos críticos en papel:** El control de combustible (*SiCC*) se sigue anotando en planillas físicas manuales, con alto riesgo de error o desvío.


* **Vacíos funcionales:** Falta de herramientas para denuncias viales ciudadanas y control de infracciones en balanzas.




* **Oportunidades (Externo):** Disponibilidad de tecnología accesible de *Business Intelligence (BI)*, herramientas *Mobile* para trabajar en terreno en las 5 Delegaciones Zonales, sistemas de información geográfica (*GIS*), inteligencia artificial/*chatbots* y posibilidad de posicionar a la DVP como referente interministerial con *GesTaller*.


* **Amenazas (Externo):** **Dependencia de proveedores (*Vendor Lock-in*)** en el sistema *Consorcio* (enlatado externo sin acceso al código fuente), riesgo patrimonial de fugas o robos de combustible/repuestos por falta de control en tiempo real, y restricciones presupuestarias estatales si no se demuestra rápido el retorno de inversión (ROI).



## Dimensión de Negocio y Crítica de Sistemas Existentes

Se define la **función de negocio principal** de cada una de las 10 Direcciones y se auditan los **10 sistemas actuales**, clasificándolos en la **Cartera de Aplicaciones Actuales (McFarlan / Edwards)** para diagnosticar cómo se están asignando hoy los recursos:

| Cuadrante Actual | Sistemas Existentes Ubicados | Diagnóstico / Crítica en el TP |
| --- | --- | --- |
| **Clave para las operaciones** *(Depende el éxito actual)* | • **StockDVP** (inventario) • **TallerDLM** (órdenes mecánicas) • **OrdenesDVP** (compras/partidas) • **Consorcio** (certificaciones) • **GesTaller** (parque provincial) • **SiCC** (cargas de combustible) | Cumplen con registrar la operación diaria, pero están fragmentados (silos), carecen de reportes analíticos, dependen de planillas manuales en papel (*SiCC*) o sufren bloqueo de proveedor sin código fuente (*Consorcio*). |
| **De Apoyo** *(Valiosos pero no críticos)* | • **Viaticar** (viáticos)  • **RopasDVP** (indumentaria)  • **RRHH** (personal y licencias)  • **Calificaciones** (desempeño)  • **LexDoctor** (juicios/amparos) | Resuelven bien las tareas administrativas y legales locales (destacándose *Calificaciones* y *LexDoctor* por digitalizar circuitos antes manuales), pero los sistemas de personal no están integrados en un legajo único ni analizan gastos. |
| **Estratégicos / Alto Potencial** | *(Vacíos en los sistemas actuales; solo figuran las propuestas futuras)* | **Diagnóstico central de la Fase II:** Todos los recursos históricos se concentraron en sistemas transaccionales aislados (operativos y de apoyo), dejando desatendidos el soporte estratégico y la innovación. |

---

# Fase III: Elaboración del Plan de $SI/TI$ (*"¿A dónde queremos ir y cómo?"*)

**Objetivo teórico:** Cruzar la estrategia del negocio con los procesos de cada área mediante la **Matriz de Necesidades (o de Alineamiento Estratégico)** para definir la **Estrategia de SI (El Qué: la demanda de información)** y traducirla en la **Estrategia de TI (El Cómo: la oferta tecnológica)**.

## Las 8 Estrategias de $SI/TI$ Derivadas de la Matriz

A partir de las necesidades no cubiertas detectadas en la Fase II, el grupo formuló **8 líneas de acción**:

| Nº | Eje / Área de Negocio | Estrategia de SI (*El Qué se necesita*) | Estrategia de TI (*El Cómo se implementa*) |
| --- | --- | --- | --- |
| **1** | **Control de Gestión Institucional** *(Alta Dirección / Administración)* | Información consolidada y en tiempo real sobre ejecución presupuestaria, flota y RR. HH. para decisiones estratégicas. | **DVP-BI:** Implementar un *Data Warehouse* que extraiga datos de todas las áreas y genere *Dashboards* y KPIs. |
| **2** | **Planificación y Análisis Territorial** *(Ingeniería, Planificación y Tecnología Vial)* | Visión georreferenciada del estado físico de la red vial, puntos críticos de accidentes y reportes ciudadanos de fallas. | **GeoVial (GIS):** Sistema de Información Geográfica interactivo con mapeo de inventario vial, accidentología y denuncias. |
| **3** | **Gestión Misional y Soberanía Tecnológica** *(Construcciones y Conservación)* | Trazabilidad exacta del avance físico vs. financiero de obras y dominio interno de certificaciones de consorcios. | **ERP Vial Integral (In-House):** Desarrollo propio evolutivo para licitaciones, certificaciones y consorcios, eliminando el *vendor lock-in*. |
| **4** | **Control de Recursos en Terreno** *(Logística y Mantenimiento)* | Control exacto, transparente y en el momento de qué vehículo y operario carga combustible y nivel de tanques en las 5 zonas. | **SiCC Móvil:** App móvil para validar cargas *in situ* (eliminando el papel) con motor de alertas de consumos atípicos. |
| **5** | **Trazabilidad del Gasto Operativo** *(Logística y Administración)* | Visión unificada de cadena de suministros y costos históricos de flota cruzados al instante con partidas presupuestarias. | **Interoperabilidad Logística (APIs):** Integrar mediante APIs *TallerDLM*, *StockDVP* y *OrdenesDVP*, eliminando los silos. |
| **6** | **Visión Integral del Capital Humano** *(Secretaría General / RR. HH.)* | Perfil unificado de cada agente (asistencia, calificaciones, indumentaria y viáticos) para gestionar el talento. | **Legajo Digital Único (Visión 360°):** Integrar por APIs los sistemas *RRHH*, *Calificaciones*, *Viaticar* y *RopasDVP*. |
| **7** | **Control de Calidad** *(Dirección de Tecnología Vial)* | Base técnica centralizada e histórica de ensayos de materiales para exigir garantías de obra a contratistas. | **LabVial:** Base de datos centralizada para resguardo digital de ensayos de laboratorio (reemplazando cuadernos/PDF sueltos). |
| **8** | **Retención Legal** *(Dirección de Asuntos Jurídicos)* | Seguimiento estricto de plazos procesales, juicios, amparos y expropiaciones en las 5 delegaciones para evitar sanciones. | **Retención de LexDoctor:** Renovar y mantener licencias del paquete estándar legal para no distraer programadores del *ERP*. |

---

## Clasificación en la Cadena de Valor (Andreu, Ricart y Valor - Cap. 2)

El TP distingue correctamente qué sistemas pertenecen a la infraestructura transversal y cuáles son locales a un eslabón:

* **Sistema de Información «Básico» (Transversales / Infraestructura de la empresa):** Atraviesan múltiples direcciones y manejan información que pertenece a la DVP globalmente: **ERP Vial Integral**, **DVP-BI**, **OrdenesDVP** y el módulo central de **RRHH**.


* **Subsistemas Circunscritos (Sistemas de Nicho):** Limitados a resolver volúmenes de información operativa específica de una actividad concreta con alta independencia: **SiCC Móvil**, **GeoVial (GIS)**, **GesTaller**, **LexDoctor**, **Viaticar**, **LabVial** y **RopasDVP**.



---

## Cartera de Aplicaciones Futuras y Estrategias Genéricas (Edwards - Cap. 6)

Para evitar la trampa de gestionar todo con una única regla universal, se ubica cada proyecto en la matriz de McFarlan y se le asigna su **estrategia genérica de gestión (Parsons)**:

1. **Estratégicas $\rightarrow$ Planificación Centralizada (orientada a la demanda del negocio, alta dirección implicada):**

* *Aplicaciones:* **ERP Vial Integral (In-House)** y **DVP-BI (Data Warehouse y Tableros)**. Informática trabaja junto al Directorio porque de ellas depende el éxito estratégico futuro y la soberanía sobre los datos misionales.




2. **De Alto Potencial $\rightarrow$ Hilo Conductor (orientada a la demanda impulsada por la innovación tecnológica):**

* *Aplicación:* **GeoVial (GIS DVP)**. Permite experimentar e innovar cruzando mapas con accidentología y reportes ciudadanos, dándoles flexibilidad a los ingenieros sin asfixiarlos con burocracia.




3. **Clave para las Operaciones $\rightarrow$ Monopolio (orientada al control central de la oferta para evitar riesgos operativos):**

* *Aplicaciones:* **Sistemas Logísticos Integrados (*TallerDLM + StockDVP*)**, **OrdenesDVP**, **GesTaller**, **SiCC Móvil** y **LabVial**. Informática ejerce control estricto como proveedor único para asegurar estabilidad, integridad de datos y que la operatoria diaria no se detenga.




4. **De Apoyo $\rightarrow$ Recurso Escaso (orientada a la oferta con restricción presupuestaria y justificación económica):**

* *Aplicaciones:* **Legajo Digital Único (*RRHH + Calificaciones + Viaticar + RopasDVP*)** y **LexDoctor**. Se invierte lo mínimo indispensable (integración liviana por APIs o pago de licencia anual estándar) para liberar fondos y programadores hacia el *Core* del negocio (el ERP).





---

## Valor de la Información, Beneficios e Inversiones (Robson - Cap. 7)

El TP justifica el plan cruzando dos modelos fundamentales del capítulo 7 de Robson:

**1. Matriz de Beneficios Genéricos (Modelo de Silk y las 3 Eras de la Información):**

* **Eficiencia (Nivel Operacional – Era $E1$: Automatizar – Técnica de justificación "Dura" / Tangibles):** Se mide con ahorros financieros cuantificables usando conceptos de la Economía de la Información (Parker y Benson):


* *Desplazamiento de costos y ahorro de tiempo (*SiCC Móvil*):* Ahorra **USD 18.000/año** en papel/impresión/traslado y reduce un **45 %** el tiempo de carga (**120 horas-hombre/mes** liberadas).


* *Reducción de ciclo y evitación de costos (*Sistemas logísticos integrados*):* Baja un **40 %** el *time-to-repair* y reduce un **15 %** el stock ocioso, evitando inmovilizar **USD 25.000** el primer año.


* *Aceleración del valor y evitación de mora (*ERP Vial Integral*):* Reduce la aprobación de certificados de obra de **45 a 12 días**, evitando pagar **USD 35.000/año** en intereses por mora a contratistas.


* *Evitación de costos por control de calidad (*LabVial*):* Evita un **8 %** de gastos en bacheo prematuro al poder ejecutar legalmente las garantías de obra con ensayos auditables.




* **Efectividad (Nivel Táctico – Era $E2$: Informar – Técnica de justificación "Blanda" / Mayor RoA):** Mejora la toma de decisiones de los directores intermedios y el rendimiento de los activos:


* Mayor disponibilidad física de maquinaria vial gracias a la integración logística.


* *DVP-BI* funciona como un **DSS (Sistema de Soporte a las Decisiones)** para corregir desvíos del Fondo Vial a tiempo.


* *Legajo Digital Único* permite ascensos objetivos por mérito real, mejorando la motivación.




* **Avance Estratégico (Nivel Estratégico – Era $E3$: Transformar – Justificación por "Acto de fe" / Intangibles de largo plazo):**

* *Reconfiguración de la cadena de valor (*ERP Vial In-House*):* Rompe la asimetría de información y cambia el poder de negociación frente a las empresas constructoras contratistas.


* *Transformación del rol institucional (*GeoVial GIS*):* Pasa de reparar baches de forma reactiva a planificar preventivamente según el Factor Crítico de Éxito (FCE) de reducir la mortalidad en rutas.





**2. Estilos de Inversión (Categorías puras de Robson):**

* **Según el impacto deseado:**

* *Valor Operacional (corto plazo, hacer mejor lo que ya se hace):* *SiCC Móvil*, *Sistemas logísticos integrados*, *Legajo Digital Único* y *LabVial*.


* *Valor Estratégico (largo plazo, crecimiento/transformación):* *ERP Vial Integral*, *GeoVial (GIS)* y *DVP-BI*.




* **Según la necesidad de inversión:**

* *Inversión de Umbral (obligatoria para operar y cumplir normas sin quedar fuera de regla):* Licencias de **LexDoctor**.


* *Inversión de Infraestructura (mediano plazo, genera capacidad instalada/cimientos para otros sistemas):* **Arquitectura de Interoperabilidad basada en APIs**.





---

# Fase IV: Programación de Actividades (*"Ejecución y Control a Corto Plazo"*)

**Objetivo teórico:** Es una fase eminentemente técnica liderada por el **DOP (Director Operativo del Proyecto)** y aprobada por el Comité de $TI/SI$, donde el Plan de $SI/TI$ se traduce en un calendario anual, un presupuesto y mecanismos de control.

* **Proyecto priorizado para iniciar:** Tras validar con las Direcciones de Construcciones y Conservación, el Comité de $TI/SI$ aprueba ejecutar el **Sistema Integrado Misional (ERP Vial In-House + SIG GeoVial + DVP-BI)** bajo un enfoque incremental para mitigar riesgos:


* **Paso IV.1 – Calendario del Primer Año (12 meses) y proyección a 18 meses:**

* *Hito 1 (Meses 1 a 4):* Lanzamiento del Mapa Base e Inventario Vial (**GeoVial**).


* *Hito 2 (Meses 5 a 10):* Despliegue del Módulo de Construcciones del **ERP** (certificaciones y avance físico-financiero).


* *Hito 3 (Meses 11 a 12):* Integración espacial (*ERP + GeoVial*) y tableros gerenciales (**DVP-BI**).


* *Hito 4 (Mediano plazo, Meses 13 a 18):* Módulo de Consorcios Camineros y capacitación presencial en las 5 Delegaciones Zonales.




* **Paso IV.2 – Presupuesto y Asignación de Recursos (Los 3 recursos de Chiavenato aplicados a TI):**

* *Recursos Humanos:* 1 Analista Funcional / DOP (1.920 hs-hombre anuales, dedicación 100 %), 1 Programador Senior Full-Stack (1.920 hs-hombre anuales, 100 %) e ingenieros *Key Users* de las direcciones (240 hs-hombre anuales, 5 hs/semana para validación).


* *Recursos Tecnológicos (Plan de HW y SW de base):* Software base *Open Source* (`PostgreSQL`/`PostGIS`, `Node.js`) para costo cero de licencias y soberanía tecnológica; compra/asignación de **2 servidores de alto rendimiento** (App/BD y Servidor GIS) y **2 Workstations** de desarrollo.


* *Recursos Financieros:* Honorarios del equipo por 12 meses + capital para hardware + **15 % de fondo de contingencia** ante imprevistos.




* **Paso IV.3 – Plan de Evaluación y Revisión (Mecanismos de Control):**

* *Control preventivo/iterativo:* Validación de prototipos visuales (*Mockups*) con los usuarios clave antes de programar cada módulo.


* *Control por hitos:* Al cierre de cada uno de los 4 hitos, el DOP presenta al Comité de $TI/SI$ un informe midiendo dos variables duras: **cumplimiento de plazos** y **ejecución presupuestaria**.







---

# 💡 Tres preguntas típicas de defensa oral sobre este TP (y cómo responderlas)

1. ***"¿Por qué decidieron desarrollar el ERP Vial de forma interna (In-House) en vez de comprar un enlatado, pero en Asuntos Jurídicos mantuvieron el enlatado LexDoctor?"***

* *Respuesta:* Por su posición en la **cartera de aplicaciones**. La gestión de obras, certificaciones y consorcios es el *Core* misional de Vialidad (aplicación **estratégica**); hoy sufren *vendor lock-in* con el sistema externo *Consorcio* porque no tienen el código fuente. Desarrollar el ERP *In-House* bajo *Planificación Centralizada* les devuelve soberanía tecnológica. En cambio, Asuntos Jurídicos usa una aplicación **de apoyo** (inversión **de umbral**); como no da ventaja competitiva sino que cumple normas legales estándar, bajo la estrategia de *Recurso Escaso* conviene pagar la licencia de *LexDoctor* y no gastar horas de programación propias que hacen falta en el ERP.




2. ***"¿Por qué en la Cartera de la Fase II ponen a GesTaller y OrdenesDVP en 'Clave para las operaciones', si en la Cadena de Valor dicen que OrdenesDVP es un 'SI Básico' y GesTaller es un 'Subsistema Circunscrito'?"***

* *Respuesta:* Porque son dos clasificaciones con criterios distintos. **Andreu, Ricart y Valor** clasifican según el **alcance en la cadena de valor**: *OrdenesDVP* es *SI Básico* porque atraviesa como infraestructura financiera a todas las direcciones, mientras que *GesTaller* es *circunscrito* porque se limita a la actividad específica del taller mecánico. En cambio, **McFarlan/Edwards** clasifican según la **contribución al éxito del negocio**: ambos son *Clave para las operaciones* porque si hoy se cae las órdenes de compra o la gestión del taller, la operatoria diaria de Vialidad se frena.




3. ***"¿Dónde se ve reflejado el enfoque sociotécnico de Tavistock (Chiavenato) en este TP?"***

* *Respuesta:* En que la modernización no se plantea solo como comprar servidores o programar código (**subsistema técnico**), sino que transforma los procesos de toma de decisiones, control y auditoría del Directorio (**subsistema gerencial**) e involucra activamente a las personas (**subsistema social**) mediante la participación de los *Key Users* en el Equipo de Trabajo, la validación de *Mockups*, las capacitaciones en las 5 Delegaciones Zonales (Hito 4) y el *Legajo Digital Único* para motivar al personal con ascensos por mérito.





¿Querés que armemos un resumen tipo "machete de una carilla" con la línea conductora del TP para tener a mano, o preferís repasar alguna fase en particular?

