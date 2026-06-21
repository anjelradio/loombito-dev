import io
from datetime import date
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle

class BoletinPdfBuilder:
    def __init__(self, school_name: str, course_name: str, level_name: str, student_name: str, birth_date: date | None, terms: list[str]):
        self.school_name = school_name
        self.course_name = course_name
        self.level_name = level_name
        self.student_name = student_name
        self.birth_date = birth_date
        self.terms = terms
        self.dataset = []

    def add_row(self, subject: str, term_scores: list[float], annual_avg: float):
        self.dataset.append({
            "subject": subject,
            "term_scores": term_scores,
            "annual_avg": annual_avg
        })

    def build(self) -> bytes:
        buffer = io.BytesIO()
        # Bolivian libretas are usually landscape
        doc = SimpleDocTemplate(
            buffer,
            pagesize=landscape(letter),
            leftMargin=30,
            rightMargin=30,
            topMargin=30,
            bottomMargin=30,
        )

        styles = getSampleStyleSheet()
        
        # Custom styles for Bolivian design
        title_style = ParagraphStyle(
            'TitleStyle',
            parent=styles['Heading1'],
            fontName='Helvetica-Bold',
            fontSize=15,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#1A365D"),
            spaceAfter=12
        )
        
        subtitle_style = ParagraphStyle(
            'SubtitleStyle',
            parent=styles['Normal'],
            fontName='Helvetica-Bold',
            fontSize=11,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#2B6CB0"),
            spaceAfter=6
        )
        
        info_style = ParagraphStyle(
            'InfoStyle',
            parent=styles['Normal'],
            fontName='Helvetica',
            fontSize=10,
            alignment=TA_LEFT,
            spaceAfter=6
        )

        story = []

        # Header - Official Bolivian styling
        story.append(Paragraph("ESTADO PLURINACIONAL DE BOLIVIA", subtitle_style))
        story.append(Paragraph("MINISTERIO DE EDUCACIÓN", subtitle_style))
        story.append(Spacer(1, 10))
        story.append(Paragraph("BOLETÍN CENTRALIZADOR DE CALIFICACIONES", title_style))
        story.append(Paragraph("SUBSISTEMA DE EDUCACIÓN REGULAR", subtitle_style))
        story.append(Spacer(1, 20))
        
        # Student and Course Info
        birth_str = self.birth_date.strftime("%d/%m/%Y") if self.birth_date else "N/A"
        
        info_data = [
            [Paragraph(f"<b>Unidad Educativa:</b> {self.school_name}", info_style),
             Paragraph(f"<b>Nivel:</b> {self.level_name}", info_style)],
            [Paragraph(f"<b>Estudiante:</b> {self.student_name}", info_style),
             Paragraph(f"<b>Año de Escolaridad / Curso:</b> {self.course_name}", info_style)],
            [Paragraph(f"<b>Fecha de Nacimiento:</b> {birth_str}", info_style),
             Paragraph(f"<b>Gestión Escolar:</b> {date.today().year}", info_style)],
        ]
        
        info_table = Table(info_data, colWidths=['60%', '40%'])
        info_table.setStyle(TableStyle([
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
            ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ]))
        
        story.append(info_table)
        story.append(Spacer(1, 15))

        # Grades Table
        headers = ["CAMPOS / ÁREAS DE SABERES Y CONOCIMIENTOS"] + [t.upper() for t in self.terms] + ["PROMEDIO ANUAL"]
        table_data = [headers]
        
        for row in self.dataset:
            # Format numbers safely. Usually in Bolivia grades are integers out of 100
            scores_formatted = [f"{score:.0f}" if score > 0 else "-" for score in row["term_scores"]]
            avg_formatted = f"{row['annual_avg']:.0f}" if row['annual_avg'] > 0 else "-"
            table_data.append([row["subject"]] + scores_formatted + [avg_formatted])
            
        col_widths = [250] + [90]*len(self.terms) + [110]
        grades_table = Table(table_data, colWidths=col_widths, repeatRows=1)
        
        # Table Styling - Professional clean look
        grades_table.setStyle(TableStyle([
            # Header row
            ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1f4d7d")),
            ('TEXTCOLOR', (0,0), (-1,0), colors.white),
            ('ALIGN', (0,0), (-1,0), 'CENTER'),
            ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
            ('FONTSIZE', (0,0), (-1,0), 9),
            ('BOTTOMPADDING', (0,0), (-1,0), 10),
            ('TOPPADDING', (0,0), (-1,0), 10),
            
            # Content
            ('ALIGN', (0,1), (0,-1), 'LEFT'),
            ('ALIGN', (1,1), (-1,-1), 'CENTER'),
            ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'), # Subjects in bold
            ('FONTNAME', (1,1), (-1,-1), 'Helvetica'),
            ('FONTSIZE', (0,1), (-1,-1), 9),
            ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#A9BDD4")),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
            ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#f8fbff")]),
            
            # Final column (Promedio) highlight
            ('BACKGROUND', (-1,1), (-1,-1), colors.HexColor("#eef6ff")),
            ('FONTNAME', (-1,1), (-1,-1), 'Helvetica-Bold'),
        ]))
        
        story.append(grades_table)
        story.append(Spacer(1, 50))
        
        # Signatures
        sig_data = [
            ["___________________________", "___________________________", "___________________________"],
            ["Firma Docente / Tutor", "Sello y Firma Director(a)", "Firma Padre/Madre/Tutor"]
        ]
        sig_table = Table(sig_data, colWidths=['33%', '34%', '33%'])
        sig_table.setStyle(TableStyle([
            ('ALIGN', (0,0), (-1,-1), 'CENTER'),
            ('FONTNAME', (0,1), (-1,1), 'Helvetica'),
            ('FONTSIZE', (0,1), (-1,1), 8),
            ('TEXTCOLOR', (0,1), (-1,1), colors.HexColor("#4A5568")),
            ('TOPPADDING', (0,1), (-1,1), 5),
        ]))
        
        story.append(sig_table)

        doc.build(story)
        buffer.seek(0)
        return buffer.getvalue()
